From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] tun: avoid owner checks on IFF_ATTACH_QUEUE
Date: Thu, 10 Jan 2013 12:55:03 +0100
Message-ID: <20130110115503.GD30885@stefanha-thinkpad.redhat.com>
References: <20130110113108.GF13451@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130110113108.GF13451@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 10, 2013 at 01:31:08PM +0200, Michael S. Tsirkin wrote:
> At the moment, we check owner when we enable queue in tun.
> This seems redundant and will break some valid uses
> where fd is passed around: I think TUNSETOWNER is there
> to prevent others from attaching to a persistent device not
> owned by them. Here the fd is already attached,
> enabling/disabling queue is more like read/write.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> ---
> 
> Note: this is unrelated to Stefan's bugfix.

This should go into 3.8-rc.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

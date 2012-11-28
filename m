From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: fix length for cross region descriptor
Date: Wed, 28 Nov 2012 11:27:15 -0500 (EST)
Message-ID: <20121128.112715.652916144298491861.davem@davemloft.net>
References: <20121126155727.GA21716@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121126155727.GA21716@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 26 Nov 2012 17:57:27 +0200

> If a single descriptor crosses a region, the
> second chunk length should be decremented
> by size translated so far, instead it includes
> the full descriptor length.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks.

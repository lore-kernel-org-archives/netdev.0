From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] tun: fix recovery from gup errors
Date: Mon, 24 Jun 2013 07:31:13 -0400
Message-ID: <20130624113113.GA25233@hmsreliant.think-freely.org>
References: <20130623141903.GA21029@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Brad Hubbard <bhubbard@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130623141903.GA21029@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 23, 2013 at 05:19:03PM +0300, Michael S. Tsirkin wrote:
> get user pages might fail partially in tun zero copy
> mode. To recover we need to put all pages that we got,
> but code used a wrong index resulting in double-free
> errors.
> 
> Reported-by: Brad Hubbard <bhubbard@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> I haven't figured out why do we get failures,
> but recovery is clearly wrong.
> 
> This is also -stable material.
> 
>  drivers/net/tun.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 11:42:09 +0300
Message-ID: <20120409084208.GA28362@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <20120408234951.GA15993@gondor.apana.org.au>
 <20120409072849.GA12014@redhat.com>
 <20120409073354.GA3218@gondor.apana.org.au>
 <20120409073953.GD12014@redhat.com>
 <20120409082919.GA3471@gondor.apana.org.au>
 <20120409083402.GA28249@redhat.com>
 <20120409083958.GA3951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916Ab2DIImR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 04:42:17 -0400
Content-Disposition: inline
In-Reply-To: <20120409083958.GA3951@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 09, 2012 at 04:39:58PM +0800, Herbert Xu wrote:
> On Mon, Apr 09, 2012 at 11:34:02AM +0300, Michael S. Tsirkin wrote:
> >
> > Puzzled. This patch orphans skbs only if the destination device sets
> > IFF_TX_CAN_STALL.  Since the physical NIC doesn't stall forever it never
> > sets this flag.
> > 
> > So it seems that this patch should not affect the configuration
> > you describe at all.
> > 
> > Could you please clarify? What did I miss?
> 
> Oops, you're right.  Somehow I was thinking you were patching
> virtio-net instead of tun.
> 
> Cheers,

Cool. Want to ack the patch then just to make it clear you are happy?

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

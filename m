From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 13:19:04 +0300
Message-ID: <20100719101904.GA31743@redhat.com>
References: <20100610124047.GA16658@gondor.apana.org.au>
 <20100610074912.1303e3da@nehalam>
 <20100610215643.GA22048@gondor.apana.org.au>
 <20100610145915.721a86b7@nehalam>
 <20100610224839.GA22469@gondor.apana.org.au>
 <20100611021142.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760454Ab0GSKYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 06:24:32 -0400
Content-Disposition: inline
In-Reply-To: <20100611021142.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 11, 2010 at 12:11:42PM +1000, Herbert Xu wrote:
> On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> > On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
> > >
> > > Okay, then add a comment where in_irq is used?
> > 
> > Actually let me put it into a wrapper.  I'll respin the patches.
> 
> OK here is a repost.  And this time it really is 8 patches :)
> I've tested it lightly.
> 
> Cheers,

Meanwhile, should we just disable netpoll for bridge in 2.6.35 and -stable?
We are getting crash reports in virtualization which I suspect are
related to this:
https://bugzilla.kernel.org/show_bug.cgi?id=16413

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

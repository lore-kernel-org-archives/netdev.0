From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 18:53:00 +0800
Message-ID: <20100719105300.GA22179@gondor.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au> <20100610074912.1303e3da@nehalam> <20100610215643.GA22048@gondor.apana.org.au> <20100610145915.721a86b7@nehalam> <20100610224839.GA22469@gondor.apana.org.au> <20100611021142.GA24490@gondor.apana.org.au> <20100719101904.GA31743@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43262 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760503Ab0GSKxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 06:53:09 -0400
Content-Disposition: inline
In-Reply-To: <20100719101904.GA31743@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 01:19:04PM +0300, Michael S. Tsirkin wrote:
> On Fri, Jun 11, 2010 at 12:11:42PM +1000, Herbert Xu wrote:
> > On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> > > On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
> > > >
> > > > Okay, then add a comment where in_irq is used?
> > > 
> > > Actually let me put it into a wrapper.  I'll respin the patches.
> > 
> > OK here is a repost.  And this time it really is 8 patches :)
> > I've tested it lightly.
> > 
> > Cheers,
> 
> Meanwhile, should we just disable netpoll for bridge in 2.6.35 and -stable?
> We are getting crash reports in virtualization which I suspect are
> related to this:
> https://bugzilla.kernel.org/show_bug.cgi?id=16413

I think that's probably the best solution, Dave?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

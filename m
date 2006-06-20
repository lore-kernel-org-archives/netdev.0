From: David Miller <davem@davemloft.net>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Tue, 20 Jun 2006 03:40:11 -0700 (PDT)
Message-ID: <20060620.034011.104035301.davem@davemloft.net>
References: <20060620090919.GA31613@gondor.apana.org.au>
	<20060620093219.GF31854@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14811
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932558AbWFTKkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:40:04 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060620093219.GF31854@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Jun 2006 19:32:19 +1000

> On Tue, Jun 20, 2006 at 07:09:19PM +1000, herbert wrote:
> >
> > I've attached some numbers to demonstrate the savings brought on by
> > doing this.  The best scenario is obviously the case where the underlying
> > NIC supports SG.  This means that we simply have to manipulate the SG
> > entries and place them into individual skb's before passing them to the
> > driver.  The attached file lo-res shows this.
> 
> Obviously I forgot to attach them :)

:-)

The changes look good on first scan, I'll look more deeply and
meanwhile we'll let the patches ferment for a few days so others
can comment too :-)

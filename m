From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 16:07:46 -0800 (PST)
Message-ID: <20081218.160746.58836056.davem@davemloft.net>
References: <20081218224905.2bc81664@lxorguk.ukuu.org.uk>
	<20081218230253.GA1855@gondor.apana.org.au>
	<20081218231407.4096a64e@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751318AbYLSAHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 19:07:44 -0500
In-Reply-To: <20081218231407.4096a64e@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 18 Dec 2008 23:14:07 +0000

> On Fri, 19 Dec 2008 10:02:53 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Well
> > 
> > $ grep fire drivers/char/lp.c
> >                         printk(KERN_INFO "lp%d on fire\n", minor);
> 
> Interesting. It got changed and then the change got lost between 2.2 and
> 2.4 somewhere. It was changed to report
> 
> "lp0 reported invalid error status (on fire, eh?)"
> 
> and it looks like that needs re-fixing.

This is just proof that it doesn't matter.  If it got lost in
2.4.x that means it's been like this forever as far as %99
of current systems are concerned.

I'm all for seriousness, but if we can't have some comedic license
with a few kernel log messages then the fun of kernel development
truly suffers :-)

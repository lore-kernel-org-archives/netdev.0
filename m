From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 23:14:07 +0000
Message-ID: <20081218231407.4096a64e@lxorguk.ukuu.org.uk>
References: <1229638581.3726.546.camel@calx>
	<E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au>
	<20081218224905.2bc81664@lxorguk.ukuu.org.uk>
	<20081218230253.GA1855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42638 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752270AbYLRXOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 18:14:05 -0500
In-Reply-To: <20081218230253.GA1855@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2008 10:02:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Dec 18, 2008 at 10:49:05PM +0000, Alan Cox wrote:
> >
> > It was changed. The printer on fire ? bit was adjusted to make it clear
> > because the original message *did* confuse and worry a few people.
> 
> Well
> 
> $ grep fire drivers/char/lp.c
>                         printk(KERN_INFO "lp%d on fire\n", minor);

Interesting. It got changed and then the change got lost between 2.2 and
2.4 somewhere. It was changed to report

"lp0 reported invalid error status (on fire, eh?)"

and it looks like that needs re-fixing.

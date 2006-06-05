From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Mon, 05 Jun 2006 12:35:29 +0200
Message-ID: <1149503730.3111.46.camel@laptopd505.fenrus.org>
References: <20060604135011.decdc7c9.akpm@osdl.org>
	 <20060605010636.GB17361@havoc.gtf.org>
	 <20060604181515.8faa8fcf.akpm@osdl.org>
	 <20060605083321.GA15690@rhlx01.fht-esslingen.de>
	 <1149497109.3111.28.camel@laptopd505.fenrus.org>
	 <1149503215.30554.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	acx100-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:61675 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750905AbWFEKfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 06:35:37 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1149503215.30554.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-05 at 11:26 +0100, Alan Cox wrote:
> Ar Llu, 2006-06-05 am 10:45 +0200, ysgrifennodd Arjan van de Ven:
> >  It's just that a cleanroom approach is a sure way to prove
> > you didn't copy. That's all.
> 
> Which is an extremely important detail especially if you have been
> reverse engineering another driver for the same or similar OS where it
> is likely that people will retain knowledge and copy rather than
> re-implement things.

oh don't get me wrong, it's important to not copy from the original.
(even if that original did copy from linux ;)


> We've had "fun" with this before and the pwc camera driver. I don't want
> to see a repeat of that.

yet at the same time, the cleanroom approach is not the ONLY way to do
it right. And making following that exact approach a strict requirement
is just silly. And it would mean we'd need to remove quite a few drivers
from the tree if you follow that logic.

And to be fair the pwc camera driver was just a guy with a personality
problem rather than any real legal standing. 

Again doing things right is important. But I would say that if you do
the rev-engineering in Europe, just being careful and avoiding copying
should be enough (well and certifying that you were in fact careful and
didn't do any copying).



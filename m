From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH (take 2)] request_irq fix DEBUG_SHIRQ handling Re: 2.6.23-rc2-mm1: rtl8139 inconsistent lock state
Date: Fri, 24 Aug 2007 07:46:47 +0200
Message-ID: <20070824054647.GA1648@ff.dom.local>
References: <200708100149.14446.m.kozlowski@tuxland.pl> <20070823084430.GB1980@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:53886 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750815AbXHXFpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 01:45:39 -0400
Content-Disposition: inline
In-Reply-To: <20070823084430.GB1980@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 23, 2007 at 10:44:30AM +0200, Jarek Poplawski wrote:
> Andrew Morton pointed out that my changelog was unusable. Sorry!
> Here is a second try with the changelog and kernel version changed.
...
> ------------>(take 2)
> 
> Subject: request_irq() - fix DEBUG_SHIRQ handling
...
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> ---
> 
> diff -Nurp 2.6.23-rc3-git6-/kernel/irq/manage.c 2.6.23-rc3-git6/kernel/irq/manage.c
> --- 2.6.23-rc3-git6-/kernel/irq/manage.c	2007-08-23 10:11:35.000000000 +0200
> +++ 2.6.23-rc3-git6/kernel/irq/manage.c	2007-08-23 10:16:29.000000000 +0200

So, this time I f-ed the diff part: it's not exactly against 2.6.23-rc-git6.
But, it's Andrew to blame: he should've known that some old & slow chips
can't do science and poetry at the same time. Sorry (for him)!

Anyway, beside an offset, should be OK...

Regards,
Jarek P.

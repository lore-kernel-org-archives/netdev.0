From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 08 Jun 2006 11:38:52 -0400
Message-ID: <4488448C.8050504@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608152221.GC8246@colo.lackof.org> <20060608153235.GD8246@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7887 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964882AbWFHPi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:38:56 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060608153235.GD8246@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> Ok...I think I understand what you are driving at here.
> The case is when CPU vector is enabled and shared but
> one device _without_ an interrupt handler is registered
> is still yanking on the interrupt line. It will cause
> linux to disable the line since the IRQ isn't being handled.

Correct.


> Can we call free_irq() from tulip_down()?

I'm sure you can answer that yourself.  If it doesn't cause problems 
elsewhere, yes.  Otherwise, no.  :)

Did you read the example I cited, cp_close() ?

	Jeff



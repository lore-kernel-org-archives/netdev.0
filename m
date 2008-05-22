From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2] [NET] uli526x: add support for netpoll
Date: Thu, 22 May 2008 06:21:52 -0400
Message-ID: <48354940.40100@pobox.com>
References: <20080515151255.GA12408@polina.dev.rtsoft.ru> <200805152251.24137.florian.fainelli@telecomint.eu> <20080516111349.GA27587@polina.dev.rtsoft.ru> <20080516190451.GA20860@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Florian Fainelli <florian.fainelli@telecomint.eu>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936821AbYEVKV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:21:56 -0400
In-Reply-To: <20080516190451.GA20860@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> This patch adds netpoll support for the uli526x ethernet driver --
> simply call the interrupt handler for polling.
> 
> To do this without disable_irq()/enable_irq() pair we should fully
> protect the handler. Luckily, it's already using irqsave spinlock,
> the only unprotected place is interrupts re-enabling write. It was
> safe to re-enable interrupts without holding the spinlock, but with
> netpoll possibility now it doesn't seem so.
> 
> Patch was tested using netconsole and KGDBoE.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

applied



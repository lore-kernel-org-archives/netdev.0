From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.26-git] enc28j60: don't specify (wrong) IRQ type
Date: Tue, 29 Jul 2008 18:24:57 -0400
Message-ID: <488F98B9.90909@pobox.com>
References: <200807241747.56954.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43918 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039AbYG2WZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 18:25:02 -0400
In-Reply-To: <200807241747.56954.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: David Brownell <dbrownell@users.sourceforge.net>
> 
> Recent changes to the IRQ framework have made passing the wrong
> trigger type to request_irq() become a fatal error.  In the case
> of the enc28j60 driver, it stopped working in my test harness.
> 
> (Specifically:  the signal detects "pin change" events, both edges,
> not just falling edges.  Similarly, other boards might route it
> through an inverter.  Trigger type are board-specific.)
> 
> This fixes that problem by the usual fix of expecting board setup
> code to have set up the correct IRQ trigger type.  The best known
> example of that being x86 setup.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

applied



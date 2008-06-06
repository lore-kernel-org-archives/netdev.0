From: Steve.Glendinning@smsc.com
Subject: phylib interrupt question
Date: Fri, 6 Jun 2008 17:07:32 +0100
Message-ID: <OF401D8BC0.37350235-ONC1257460.005643D3-80257460.00589565@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1191 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755761AbYFFQIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 12:08:00 -0400
Received: from mta.smsc.com (mta [170.129.83.113])
	by internal.smsc.com (8.12.10/8.8.5) with ESMTP id m56G7bC7011707
	for <netdev@vger.kernel.org>; Fri, 6 Jun 2008 12:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

I'm converting an ethernet driver to use phylib, and I have an interrupt 
question.  My device is an integrated mac/phy, with the option to disable 
the internal phy and use an external phy instead.  I've succesfully used 
phylib in polling mode, but I'd like to convert this to be 
interrupt-driven if possible.

When using the internal phy, it can raise interrupts via the mac (by 
setting a "phy interrupt" bit in the mac's interrupt status register).  Is 
there a way of signalling this phy interrupt to phylib from my mac 
driver's isr?  Phylib seems to want to connect to a real irq?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com



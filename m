From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Thu, 13 Jul 2006 11:13:21 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC072239AF@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:19554 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S964787AbWGMSNY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 14:13:24 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> Freeing a kernel interrupt reservation does not imply that 
> your hardware has stopped delivering them...  in a shared 
> interrupt situation, the code sequence
> 
> 	free_irq()
> 	perform some action
> 
> could cause the kernel to call _another_ driver's interrupt 
> handling routine over and over again, until _your_ hardware 
> stops raising the interrupt condition.
> 
> 	Jeff


I guess misunderstood your original comment.  I am not "masking"
interrupts before issuing the reset.  I am shutting them off. The device
will not issue any more interrupts until it is reinitialized and
interrupts turned back on.

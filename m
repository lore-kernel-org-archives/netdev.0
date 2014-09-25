From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 0/3] defxx: DEFEA fixes and updates
Date: Thu, 25 Sep 2014 11:06:33 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:51423 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaIYK3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 06:29:38 -0400
Received: from localhost.localdomain ([127.0.0.1]:35304 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27009724AbaIYKGdMPLMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:06:33 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

 I have finally got my hands on an EISA variation of the board (DEC 
FDDIcontroller/EISA aka DEFEA) and was able to do some testing.  Here are 
initial updates to the driver that address problems I encountered so far.  
More to come later on as I get back to the system that I have in a remote 
location -- I need to double-check MMIO support and see what might have 
been causing spurious interrupts I saw with the 8259A PIC the board's 
interrupt line has been routed to.

  Maciej

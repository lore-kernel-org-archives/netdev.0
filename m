From: Don Fry <pcnet32@verizon.net>
Subject: patch acceptance question
Date: Thu, 09 Jul 2009 08:21:36 -0700
Message-ID: <1247152896.29603.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173005pub.verizon.net ([206.46.173.5]:52483 "EHLO
	vms173005pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbZGIPWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 11:22:09 -0400
Received: from [192.168.1.3] ([96.253.170.133]) by vms173005.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KMI0006CTC0KZY6@vms173005.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 09 Jul 2009 10:21:37 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was surprised today to see a change to pcnet32.c in 2.6.31-rc2-git4
which maybe I missed yesterday on netdev.  Most of the changes are okay,
but one in particular will result in some ugly printing.

What is the path that (probably janitorial) changes take that get
included in mainline?   Had I seen it before it went in I would have
commented on it then.

Old:
pcnet32: PCnet/FAST+ 79C972 at 0x1020, 00:0c:46:53:8d:0c
    tx_start_pt(0x0c00):~220 bytes, BCR18(9861):BurstWrEn BurstRdEn
NoUFlow 
    SRAMSIZE=0x1700, SRAM_BND=0x0800, assigned IRQ 21.


New:
pcnet32: PCnet/FAST+ 79C972 at 0x1020, 00:0c:46:53:8d:0c<6>  tx_start_pt
(0x0c00):~220 bytes, BCR18(9861):BurstWrEn BurstRdEn NoUFlow 
    SRAMSIZE=0x1700, SRAM_BND=0x0800, assigned IRQ 21.


Thanks,
Don Fry


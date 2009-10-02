From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Messages are printed on screen
Date: Fri, 02 Oct 2009 11:52:12 +0200
Message-ID: <ha4igd$ghh$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:38637 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468AbZJBJwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 05:52:31 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MteoV-0004un-9f
	for netdev@vger.kernel.org; Fri, 02 Oct 2009 11:52:35 +0200
Received: from 188.96.74.134 ([188.96.74.134])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 11:52:35 +0200
Received: from feldmann_markus by 188.96.74.134 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 11:52:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i am setting up my Server, with Linux Debian lenny. Therefore i am using 
  Kernel 2.6.31.1. I configured this Kernel with <make defconfig> and 
<make menuconfig>. My motherboard has 5 PCI slots and 1 AGP slot. All 
slots are in use. All devices are mapped to the following IRQ-Line:

Mass Storage Device (PCI Slot1)	IRQ-Line 11
Ethernet (PCI Slot 2) 		IRQ-Line 4
Ethernet (PCI Slot 3) 		IRQ-Line 5
Ethernet (PCI Slot 4) 		IRQ-Line 7
Ethernet (PCI Slot 5) 		IRQ-Line 11
Onboard USB-Controller		IRQ-Line 5
Onboard USB-Controller		IRQ-Line 4
Onboard USB-Controller		IRQ-Line 11
Onboard IDE			IRQ-Line 14
AGP VGA				IRQ-Line 11

As you see some of my IRQ-Lines are multiply in use, so my Server is 
working hard at his limit. The result is sometimes freezing of my 
Server, especially if there is much processing on these devices. I 
remember that with Kernel 2.6.18 my system didn't does freezing.

So i am trying to reduce the amount of this processing. I still get 
messages about dropped network packets on my Terminal, although i set up 
my <rsyslog> to save this only to </var/log>. Here is my 
</etc/rsyslog.conf>

How can i disable the output of messages (about dropped packets from my 
firewall) to my terminal ?

How can i stabilize my IRQ-System with the kernel 2.6.31.1 ?

What debug features should i disable ?

regards Markus


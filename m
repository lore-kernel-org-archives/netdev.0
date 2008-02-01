From: Switact - Thomas Roes <info@switact.nl>
Subject: R8101 driver link issue
Date: Fri, 01 Feb 2008 21:03:16 +0100
Message-ID: <47A37B04.3060909@switact.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr6.xs4all.nl ([194.109.24.26]:1476 "EHLO
	smtp-vbr6.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYBAURE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 15:17:04 -0500
Received: from [10.0.0.19] (hierbenikweer.xs4all.nl [82.95.234.97])
	by smtp-vbr6.xs4all.nl (8.13.8/8.13.8) with ESMTP id m11K3J5M023992
	for <netdev@vger.kernel.org>; Fri, 1 Feb 2008 21:03:19 +0100 (CET)
	(envelope-from info@switact.nl)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L.S.

I'm using linux primaliry through Novell ZEN as part of it's imaging 
system. A "standard" problem is arrival of new network cards. Procedures 
to add new drivers to the boot image are well documented.

Recently I got problems with a new motherbord using the Realtek RTL8101E 
PCI Express Fast Ethernet controller.

This card is recognised by the r8169 driver but.... it always gives me 
"link down".

To troubleshoot this issue I installed SLED10SP1 on such a machine, 
which uses the same kernel as the ZEN imaging environment.

So i searched for drivers to compile and came across the 
r8101-1.006.tar.bz2 driver.

-1 To get this driver compiled, I have to edit the source at line 3273:
u32 mss = skb_shinfo(skb)->tso_size;
replace
tso_size -> gso_size (or simply removing the if else endif construction 
altogether :-)

-2 but unfortunately, also this new driver, although it get's loaded, it 
still reports (ethtool eth0)....
current message level : 0x0..033 (51)
Link detected : no


I hope I'm writing to the right person to help solve this issue

This link detection issue seems to trouble realtek drivers for a long time.

-- 
Thomas Roes
Switact
Kvk: Leiden 28100283


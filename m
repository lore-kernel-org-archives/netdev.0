From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: PCI runtime power management for r8169
Date: Sat, 24 Apr 2010 13:30:47 +0200
Message-ID: <hqukp7$nh8$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47309 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab0DXLbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Apr 2010 07:31:03 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O5dZZ-0002rw-Ay
	for netdev@vger.kernel.org; Sat, 24 Apr 2010 13:30:57 +0200
Received: from 188.96.65.76 ([188.96.65.76])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 13:30:57 +0200
Received: from feldmann_markus by 188.96.65.76 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 13:30:57 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

as i read in this mailing list, there is/will be a power management for 
the r8169 driver?! I have the following devices:
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
04:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
04:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
04:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)


Not all of them are used at the same time. So how can i put the unused 
in a low power state?

regards Markus


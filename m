From: Bas Nedermeijer <bas@tcfaa.nl>
Subject: Setting shutdownspeed in r8169 driver
Date: Tue, 24 May 2011 23:02:40 +0200
Message-ID: <201105242302.40221.bas@tcfaa.nl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1.concepts.nl ([213.197.30.124]:43387 "EHLO
	smtp-1.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab1EXVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:18:18 -0400
Received: from 2ee3ea8b.ftth.concepts.nl ([46.227.234.139] helo=crashalot.intranet)
	by smtp-1.concepts.nl with esmtp (Exim 4.72)
	(envelope-from <bas@tcfaa.nl>)
	id 1QOykS-0003FS-W7
	for netdev@vger.kernel.org; Tue, 24 May 2011 23:02:41 +0200
Received: from localhost (unknown [127.0.0.1])
	by crashalot.intranet (Postfix) with ESMTP id EC82E94473
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 21:02:40 +0000 (UTC)
Received: from crashalot.intranet ([192.168.6.173])
	by localhost (crashalot.intranet [192.168.6.173]) (amavisd-new, port 10024)
	with ESMTP id 2n07reP1B7xD for <netdev@vger.kernel.org>;
	Tue, 24 May 2011 23:02:40 +0200 (CEST)
Received: from helium.localnet (helium.intranet [192.168.6.180])
	by crashalot.intranet (Postfix) with ESMTP id 5F0A894472
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 23:02:40 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I currently have an onboard nic, which allows me to use wake-on-lan. But link-
speed goes to 10MBit when the system is shutdown. This causes a multicast/IPTV  
stream to be throttled back to 10Mbit. This is probably because the multicast 
stream actually a broadcast on my local network. I think some device is 
sending ethernet-pause frames (havent seem them, but not sure if they show up 
in tcpdump). I tried to disable flow-control on the sending device, but that 
didnt help, still the traffic is throttled when it has passed some switches. I 
read somewhere the windows driver has an option to specify the shutdown-
linkspeed, so listening for WOL happens on 100mbit. I was wondering if it is 
possible at all with the linux-driver (maybe as default by modifying the 
driver locally as I cant seem to find a userspace program to modify the 
settings).

I am using the driver "r8169"

According to 'lspci':

Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet 
controller (rev 02)

Best regards,

Bas Nedermeijer

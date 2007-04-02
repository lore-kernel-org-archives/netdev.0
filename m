From: "Peter Trifonov" <petert@dcn.infos.ru>
Subject: PROBLEM: sky2 hangs
Date: Mon, 2 Apr 2007 22:12:27 +0400
Message-ID: <20070402181228.198B54AC19@dcn.infos.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-9cor.infos.ru ([195.209.229.106]:50735 "EHLO dcn.infos.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965632AbXDBSoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 14:44:46 -0400
Received: from dcn.research.dcn (localhost.research.dcn [127.0.0.1])
	by dcn.research.dcn (Postfix) with SMTP id 4B0B64AC7F
	for <netdev@vger.kernel.org>; Mon,  2 Apr 2007 22:12:37 +0400 (MSD)
Received: from kas30pipe.localhost (localhost.research.dcn [127.0.0.1])
	by dcn.infos.ru (Postfix) with ESMTP id 378384AC66
	for <netdev@vger.kernel.org>; Mon,  2 Apr 2007 22:12:28 +0400 (MSD)
Received: from bomb (bomb.research.dcn [10.0.103.25])
	by dcn.infos.ru (Postfix) with ESMTP id 198B54AC19
	for <netdev@vger.kernel.org>; Mon,  2 Apr 2007 22:12:28 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have got a PC based on Gigabyte GA-965P-S3 motherboard with an integrated
Marvell Yukon 88E8056 PCI-E gigabit ethernet controller. 

I am using OpenSuSe Linux 10.2 x64/SMP  with 2.6.18.2-34-default kernel.

Everything works fine when the network load is low. However, if a big file
transfer is initiated,
the network stops working completely,  and the following message is logged:

Apr  2 20:44:07 bullet-lin kernel: sky2 0000:04:00.0: pci hw error (0x2010)

In some cases the system freezes in a short time after this. 

ifconfig up/down and reloading the sky2 kernel module does not help.
ifconfig says also "unknown device 4364 rev. 13"

The driver provided by Marvell fails to compile. 

Everything works perfectly under WinXP x64.


Please let me know if there is a way to make this NIC to work under Linux.

Many thanks in advance. 

With best regards,
P. Trifonov 



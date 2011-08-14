From: Kjun Chen <kjun-chen@sambodha.org>
Subject: r8169 hard-freezes the system on big network loads
Date: Sun, 14 Aug 2011 13:08:28 +0200
Message-ID: <201108141308.28140.kjun-chen@sambodha.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sambodha.org ([87.118.110.134]:63804 "EHLO
	mail.sambodha.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab1HNLZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 07:25:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

as I have mentioned to linux-kernel, this is perfectly reproducible: receiving 
70 MB/s or more freezes my laptop (Dell Vostro, amd64, 6 GB RAM, 8x Intel Core 
i7 CPU Q 740 @ 1.73GHz) completely, sometimes within seconds, sometimes only 
after a minute.

Watching the normal console I get loads of

r8169 0000:13:00.0: eth0: link up
r8169 0000:13:00.0: eth0: link up
[...]

one message about every 1-2 seconds (sometimes even 2 per second) while 
network is active on 2.6.37.6. Up to the latest kernel (3.0.1) this freeze 
happens. However, 2.6.32.28 works with no problems, and it doesn't show those 
"eth0: link up" messages. I haven't tried kernels between .32 and .37.

lspci says:

13:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI 
Express Gigabit Ethernet controller (rev 03)

The solution with 2.6.37 and above: use the r8168 module from the realtek 
website. I have tested it with >30 GB at rates of 112 MB/s and experienced no 
freezes anymore.

If you need any other information or help, please let me know.

cheers,
  Michael


-- 
Sambodha: The Return of True Self-Knowledge


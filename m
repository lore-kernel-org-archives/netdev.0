From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] bnx2x: crash at boot
Date: Thu, 08 Dec 2011 15:13:06 +0100
Message-ID: <1323353586.2521.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <Barak_Witkowski_<barak@broadcom.com>
	 <1323265536-9760-1-git-send-email-barak@broadcom.com>
	 <1323265536-9760-2-git-send-email-barak@broadcom.com>
	 <20111207.133903.465696982570558665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: barak@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42309 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1LHONK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 09:13:10 -0500
Received: by bkbzv3 with SMTP id zv3so1669782bkb.19
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2011 06:13:09 -0800 (PST)
In-Reply-To: <20111207.133903.465696982570558665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys

Latest net-next crashes in bnx2x_stats_init+0x678/0xc90
CR2: 000000000000000004da

# CONFIG_SCSI_BNX2X_FCOE is not set

Oh well...

bnx2x_nic_init()
bnx2x_nic_load()
bnx2x_open()
dev_change_flags()

FCOE support is good, but could we get back Ethernet support ?

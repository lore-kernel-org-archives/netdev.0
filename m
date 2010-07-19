From: August <august.seu@gmail.com>
Subject: RTL8180 : improper usage of dma_addr_t
Date: Mon, 19 Jul 2010 16:23:58 +0800
Message-ID: <AANLkTikG_N9D6s2g_HvjFFmVLf4pJDCkxuwBdLUgS4Kz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:60419 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760214Ab0GSIX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 04:23:59 -0400
Received: by gyh4 with SMTP id 4so2010917gyh.19
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 01:23:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux-kernel-version : 2.6.34
drivers/net/wireless/rtl818x/rtl8180_dev.c
__LINE__ :  500
cpu_to_le32((u32)dma + ((i + 1) % entries) * sizeof(*ring));

Although in the x86 infrastruct, the value of dma_addr == line addr,
it is inproper usage here.

suggestion:
cpu_to_le32((u32)(&priv[0]) + ((i + 1) % entries) * sizeof(*ring));

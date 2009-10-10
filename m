From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 0/3] drivers/net/forcedeth.c: Update PHY erratas
Date: Sat, 10 Oct 2009 17:58:11 +0200
Message-ID: <1255190294-4121-1-git-send-email-manfred@colorfullife.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Manfred Spraul <manfred@colorfullife.com>
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:37666 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761886AbZJJP6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 11:58:32 -0400
Received: by bwz6 with SMTP id 6so2235067bwz.37
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2009 08:57:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ayaz,

I found sufficient documentation for Marvell 88E3016, 88E1111 and 88E1116,
Broadcom AC131 and Broadcom 50610.

Could you test the patches and then forward them again to davem?

For Broadcom 9507, I find enough specification to understand your patch.
Register 0x1c would be the shadow register, I must understand what
reading this register means.

--
	Manfred

From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v4 0/4] net: bcmgenet: Tx init improvements
Date: Mon, 23 Feb 2015 11:00:45 -0800 (PST)
Message-ID: <20150223190045.EF567221256@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:33323 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbBWTAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:00:48 -0500
Received: by qcxm20 with SMTP id m20so2353447qcx.0
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 11:00:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Four small patches to improve bcmgenet Tx init:
1. bcmgenet_init_tx_ring() cleanup
2. rework Tx queue init
3. precalculate TxCB->bd_addr
4. rename bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT

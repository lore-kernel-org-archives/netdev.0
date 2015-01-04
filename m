From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v3 0/4] net: bcmgenet: Tx init improvements
Date: Sat,  3 Jan 2015 23:45:13 -0800 (PST)
Message-ID: <20150104074513.4935422034C@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:60401 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbADHpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 02:45:15 -0500
Received: by mail-yk0-f201.google.com with SMTP id 142so982854ykq.2
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 23:45:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Four small patches to improve bcmgenet Tx init:
1. bcmgenet_init_tx_ring() cleanup
2. rework Tx queue init
3. precalculate TxCB->bd_addr
4. rename bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT

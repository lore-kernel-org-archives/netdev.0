From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 0/7] net: bcmgenet: multiple Rx queues support
Date: Wed, 25 Mar 2015 12:35:08 -0700 (PDT)
Message-ID: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:34016 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbCYTfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:11 -0400
Received: by iebtr6 with SMTP id tr6so2453706ieb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Final patch set to add support for multiple Rx queues:
1. remove priv->int0_mask and priv->int1_mask
2. modify Tx ring int_enable and int_disable vectors
3. simplify bcmgenet_init_dma()
4. tweak init_umac()
5. rework Tx NAPI code
6. rework Rx NAPI code
7. add support for multiple Rx queues

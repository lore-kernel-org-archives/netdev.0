From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: dev_weight: TX/RX orthogonality
Date: Thu, 29 Dec 2016 14:45:55 -0500 (EST)
Message-ID: <20161229.144555.1740958763290967121.davem@davemloft.net>
References: <20161229.140854.1456743873101323068.davem@davemloft.net>
        <1483039398-28017-1-git-send-email-matthias.tafelmeier@gmx.net>
        <20161229.144456.2187353715676829840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: matthias.tafelmeier@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbcL2Tp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 14:45:57 -0500
In-Reply-To: <20161229.144456.2187353715676829840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Actually, reverted, you didn't even build test this:

net/core/dev.c:3433:35: error: initializer element is not constant
 int dev_rx_weight __read_mostly = weight_p;
                                   ^~~~~~~~
net/core/dev.c:3434:35: error: initializer element is not constant
 int dev_tx_weight __read_mostly = weight_p;
                                   ^~~~~~~~

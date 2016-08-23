From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2] net: phy: Add missing of_node_put() in
 xgmiitorgmii_probe()
Date: Mon, 22 Aug 2016 18:08:44 -0700 (PDT)
Message-ID: <20160822.180844.554192467754944953.davem@davemloft.net>
References: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
        <1471819575-13389-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47213 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753407AbcHWBIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:08:45 -0400
In-Reply-To: <1471819575-13389-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 21 Aug 2016 22:46:15 +0000

> This node pointer is returned by of_parse_phandle() with
> refcount incremented in this function. of_node_put() on it
> before exitting this function.
> 
> This is detected by Coccinelle semantic patch.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.

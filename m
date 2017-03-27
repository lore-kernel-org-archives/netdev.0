From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: set rx mode during resume if interface is
 running
Date: Mon, 27 Mar 2017 16:15:34 -0700 (PDT)
Message-ID: <20170327.161534.60442857212281980.davem@davemloft.net>
References: <20170327105905.1404-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752657AbdC0XPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:15:36 -0400
In-Reply-To: <20170327105905.1404-1-jszhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jisheng Zhang <jszhang@marvell.com>
Date: Mon, 27 Mar 2017 18:59:05 +0800

> I found a bug by:
> 
> 0. boot and start dhcp client
> 1. echo mem > /sys/power/state
> 2. resume back immediately
> 3. don't touch dhcp client to renew the lease
> 4. ping the gateway. No acks
> 
> Usually, after step2, the DHCP lease isn't expired, so in theory we
> should resume all back. But in fact, it doesn't. It turns out
> the rx mode isn't resumed correctly. This patch fixes it by adding
> mvneta_set_rx_mode(dev) in the resume hook if interface is running.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

This doesn't apply cleanly to the net tree, please respin.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Sun, 06 Aug 2017 21:21:29 -0700 (PDT)
Message-ID: <20170806.212129.568625131913902231.davem@davemloft.net>
References: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: jqiaoulk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdHGEVb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:21:31 -0400
In-Reply-To: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jianming.qiao" <jqiaoulk@gmail.com>
Date: Fri,  4 Aug 2017 00:07:45 +0100

> When using Broadcom Systemport device in 32bit Platform, ifconfig can
> only report up to 4G tx,rx status, which will be wrapped to 0 when the
> number of incoming or outgoing packets exceeds 4G, only taking
> around 2 hours in busy network environment (such as streaming).
> Therefore, it makes hard for network diagnostic tool to get reliable
> statistical result, so the patch is used to add 64bit support for
> Broadcom Systemport device in 32bit Platform.
> 
> This patch provides 64bit statistics capability on both ethtool and ifconfig.
> 
> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>

Applied, thanks.

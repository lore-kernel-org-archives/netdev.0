From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: mark symbols static where possible
Date: Mon, 26 Sep 2016 02:24:31 -0400 (EDT)
Message-ID: <20160926.022431.1257530504302045777.davem@davemloft.net>
References: <1474795241-23365-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761674AbcIZGYf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:24:35 -0400
In-Reply-To: <1474795241-23365-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 25 Sep 2016 17:20:41 +0800

> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/marvell/mvneta.c:639:27: warning: no previous prototype for 'mvneta_get_stats64' [-Wmissing-prototypes]
> drivers/net/ethernet/marvell/mvneta.c:3529:5: warning: no previous prototype for 'mvneta_ethtool_set_link_ksettings' [-Wmissing-prototypes]
> 
> In fact, these two functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.

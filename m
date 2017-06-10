From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Add a fec_enet_clear_ethtool_stats() stub
 for CONFIG_M5272
Date: Sat, 10 Jun 2017 16:16:49 -0400 (EDT)
Message-ID: <20170610.161649.2086289606620760235.davem@davemloft.net>
References: <1497058642-31542-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, andrew@lunn.ch, cphealy@gmail.com,
        netdev@vger.kernel.org, paul.gortmaker@windriver.com,
        fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdFJUQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:16:51 -0400
In-Reply-To: <1497058642-31542-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri,  9 Jun 2017 22:37:22 -0300

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit 2b30842b23b9 ("net: fec: Clear and enable MIB counters on imx51")
> introduced fec_enet_clear_ethtool_stats(), but missed to add a stub
> for the CONFIG_M5272=y case, causing build failure for the
> m5272c3_defconfig.
> 
> Add the missing empty stub to fix the build failure.
> 
> Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thanks.

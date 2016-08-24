From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: lpc_eth: Check clk_prepare_enable() error
Date: Tue, 23 Aug 2016 17:12:06 -0700 (PDT)
Message-ID: <20160823.171206.848726795793109531.davem@davemloft.net>
References: <1471956500-30073-1-git-send-email-fabio.estevam@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vz@mleia.com, netdev@vger.kernel.org
To: fabio.estevam@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55965 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754210AbcHXAMH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:12:07 -0400
In-Reply-To: <1471956500-30073-1-git-send-email-fabio.estevam@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>
Date: Tue, 23 Aug 2016 09:48:20 -0300

> clk_prepare_enable() may fail, so we should better check its return
> value and propagate it in the case of failure
> 
> While at it, replace __lpc_eth_clock_enable() with a plain
> clk_prepare_enable/clk_disable_unprepare() call in order to
> simplify the code.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> Acked-by: Vladimir Zapolskiy <vz@mleia.com>
> ---
> Changes since v2:
> - Make sure to call clk_put on the new error path (Vladimir)

Applied.

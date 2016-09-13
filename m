From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: phy: xgene: Fix 'remove' function
Date: Tue, 13 Sep 2016 12:06:36 -0400 (EDT)
Message-ID: <20160913.120636.145288761809547250.davem@davemloft.net>
References: <1473623014-7801-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759411AbcIMQGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 12:06:45 -0400
In-Reply-To: <1473623014-7801-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 11 Sep 2016 21:43:34 +0200

> If 'IS_ERR(pdata->clk)' is true, then 'clk_disable_unprepare(pdata->clk)'
> will do nothing.
> 
> It is likely that 'if (!IS_ERR(pdata->clk))' was expected here.
> In fact, the test can even be removed because 'clk_disable_unprepare'
> already handles such cases.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.

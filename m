From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: free memory while
 channel destroy
Date: Sat, 12 Nov 2016 21:07:37 -0500 (EST)
Message-ID: <20161112.210737.1176459612012588179.davem@davemloft.net>
References: <1478610965-25288-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753115AbcKMCHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 21:07:39 -0500
In-Reply-To: <1478610965-25288-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue,  8 Nov 2016 15:16:05 +0200

> While create/destroy channel operation memory is not freed. It was
> supposed that memory is freed while driver remove. But a channel
> can be created and destroyed many times while changing number of
> channels with ethtool.
> 
> Based on net-next/master
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.

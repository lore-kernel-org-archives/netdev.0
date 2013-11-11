From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/arc/arc_emac: add missing
 platform_set_drvdata() in arc_emac_probe()
Date: Mon, 11 Nov 2013 14:02:31 -0500 (EST)
Message-ID: <20131111.140231.1328212761038344679.davem@davemloft.net>
References: <CAPgLHd_aDFExSewd3ENBgVU1Ru9LaV2Hwg=wjaO5ygo1qXRQQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	abrodkin@synopsys.com, vgupta@synopsys.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab3KKTCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:02:34 -0500
In-Reply-To: <CAPgLHd_aDFExSewd3ENBgVU1Ru9LaV2Hwg=wjaO5ygo1qXRQQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Nov 2013 14:15:12 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add missing platform_set_drvdata() in arc_emac_probe(), otherwise
> calling platform_get_drvdata() in arc_emac_remove() may returns NULL.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.

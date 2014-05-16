From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: resume phydev when going to RESUMING
Date: Fri, 16 May 2014 15:18:40 -0400 (EDT)
Message-ID: <20140516.151840.1337260559187267551.davem@davemloft.net>
References: <1400132134-19490-1-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, joe@perches.com,
	netdev@vger.kernel.org, xuejiancheng@huawei.com
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756626AbaEPTSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 15:18:43 -0400
In-Reply-To: <1400132134-19490-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>
Date: Thu, 15 May 2014 13:35:34 +0800

> With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
> to HALTED"), an unused PHY device will be put in a low-power mode
> using BMCR_PDOWN. Some Ethernet drivers might be calling phy_start()
> and phy_stop() from ndo_open and ndo_close() respectively, while
> calling phy_connect() and phy_disconnect() from probe and remove.
> In such a case, the PHY will be powered down during the phy_stop()
> call, but will fail to be powered up in phy_start().
> This patch fixes this scenario.
> 
> Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>

Applied, thanks.

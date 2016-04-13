From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Wed, 13 Apr 2016 14:31:25 -0500
Message-ID: <570E9E8D.50007@codeaurora.org>
References: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47844 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbcDMTb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 15:31:29 -0400
In-Reply-To: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot wrote:
>
>     drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function 'emac_mac_up':
>>> >>drivers/net/ethernet/qualcomm/emac/emac-mac.c:1076:9: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>       writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);

This doesn't happen on arm64, and I don't know how to fix it.  DIS_INT 
is defined as:

	#define DIS_INT          BIT(31)

It seems silly to add a typecast to DIS_INT.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.

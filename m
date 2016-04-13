From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Wed, 13 Apr 2016 14:55:32 -0500
Message-ID: <570EA434.30007@codeaurora.org>
References: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
 <570E9E8D.50007@codeaurora.org> <570EA09F.1070000@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Shanker Donthineni <shankerd@codeaurora.org>,
	kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54345 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbcDMTzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 15:55:46 -0400
In-Reply-To: <570EA09F.1070000@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shanker Donthineni wrote:
>>> >>     drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function 'emac_mac_up':
>>>>>>> >>>> >>drivers/net/ethernet/qualcomm/emac/emac-mac.c:1076:9: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>>> >>       writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
>> >
>> >This doesn't happen on arm64, and I don't know how to fix it.  DIS_INT is defined as:
>> >
>> >     #define DIS_INT          BIT(31)
>> >
> Try with (1U<<31).
>

Except that Gilad was previously asked to use the BIT() macros:

	https://lkml.org/lkml/2015/12/15/797

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.

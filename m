From: Shanker Donthineni <shankerd@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Wed, 13 Apr 2016 14:40:15 -0500
Message-ID: <570EA09F.1070000@codeaurora.org>
References: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
 <570E9E8D.50007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
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
To: Timur Tabi <timur@codeaurora.org>,
	kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E9E8D.50007@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/13/2016 02:31 PM, Timur Tabi wrote:
> kbuild test robot wrote:
>>
>>     drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function 'emac_mac_up':
>>>> >>drivers/net/ethernet/qualcomm/emac/emac-mac.c:1076:9: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>>       writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
>
> This doesn't happen on arm64, and I don't know how to fix it.  DIS_INT is defined as:
>
>     #define DIS_INT          BIT(31)
>
Try with (1U<<31).

> It seems silly to add a typecast to DIS_INT.
>

-- 
Shanker Donthineni
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project

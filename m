From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 11:24:07 -0500
Message-ID: <20160414162407.GA15303@rob-hp-laptop>
References: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
 <570E9E8D.50007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <570E9E8D.50007@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2016 at 02:31:25PM -0500, Timur Tabi wrote:
> kbuild test robot wrote:
> >
> >    drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function 'emac_mac_up':
> >>>>>drivers/net/ethernet/qualcomm/emac/emac-mac.c:1076:9: warning: large integer implicitly truncated to unsigned type [-Woverflow]
> >      writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
> 
> This doesn't happen on arm64, and I don't know how to fix it.  DIS_INT is
> defined as:

Probably depends on the compiler version. BTW, clang seems to throw 
errors for this type of thing.

> 
> 	#define DIS_INT          BIT(31)
> 
> It seems silly to add a typecast to DIS_INT.

BIT() should use 1U instead of 1.

Rob

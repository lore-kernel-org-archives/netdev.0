From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/5] Add support for QCA IPQ806x Ethernet GMAC
 controller
Date: Sat, 30 May 2015 17:05:05 -0700 (PDT)
Message-ID: <20150530.170505.580510463560485549.davem@davemloft.net>
References: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	mturquette@linaro.org, sboyd@codeaurora.org,
	peppe.cavallaro@st.com, agross@codeaurora.org,
	joshc@codeaurora.org, architt@codeaurora.org,
	georgi.djakov@linaro.org, wsa@the-dreams.de, rnayak@codeaurora.org,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-clk@vger.kernel.org,
	netdev@vger.kernel.org
To: mathieu@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathieu Olivari <mathieu@codeaurora.org>
Date: Wed, 27 May 2015 11:02:45 -0700

> This patch set adds support for the integrated Ethernet GMAC controller
> on QCA IPQ806x SoC. This controller is based on a Gigabit Synopsys
> DesignWare IP, already supported in the stmmac driver located in
> drivers/net/ethernet/stmicro/stmmac.
> 
> This change is done as a follow-up to the following thread:
> *http://www.spinics.net/lists/netdev/msg311265.html
> While previous attempt was creating a new driver to drive this controller,
> this new post leverages the existing stmmac driver by implementing the
> SoC specific glue to it.
> 
> Aside from the pure stmmac glue layer, we have a couple of related
> patches:
> *IPQ806x NSS clock addition is cherry-picked and refreshed from the
>  following thread: https://lkml.org/lkml/2014/8/6/390
> *phy-handle and fixed-link support are also added in this change set so the
>  driver can be fully functional on platforms using device-trees as well as
>  ethernet switches.
> 
> V2:
>  *Fix MODULE_LICENSE to "Dual BSD/GPL" as the dwmac-ipq806x.c is using
>   ISC license.

Series applied to net-next, thanks.

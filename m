From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH v2 8/9] clk: rockchip: associate SCLK_MAC_PLL and disable
 reparenting on rk3036
Date: Tue, 15 Mar 2016 11:45:35 -0700
Message-ID: <20160315184535.GG25972@codeaurora.org>
References: <1457860062-5514-1-git-send-email-wxt@rock-chips.com>
 <1457860062-5514-9-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	linux-clk@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35191 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcCOSpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:45:38 -0400
Content-Disposition: inline
In-Reply-To: <1457860062-5514-9-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13, Caesar Wang wrote:
> From: Heiko Stuebner <heiko@sntech.de>
> 
> The emac needs constant and very specific rate but the possible PLL-sources
> are very limited, so we expect the PLL source to be set manually on per
> board and don't want it to get changed in an automatic way later.
> So add the necessary clock-id and disable reparenting on set_rate calls.
> 
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>
> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
> ---

Acked-by: Stephen Boyd <sboyd@codeaurora.org>

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

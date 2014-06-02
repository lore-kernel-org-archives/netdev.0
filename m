From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851: Don't use regulator_get_optional()
Date: Sun, 01 Jun 2014 19:48:02 -0700 (PDT)
Message-ID: <20140601.194802.439655175826998004.davem@davemloft.net>
References: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	nm@ti.com, broonie@kernel.org
To: sboyd@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Wed, 28 May 2014 13:11:12 -0700

> We shouldn't be using regulator_get_optional() here. These
> regulators are always present as part of the physical design and
> there isn't any way to use an internal regulator or change the
> source of the reference voltage via software. Given that the only
> users of this driver in the kernel are DT based, this change
> should be transparent to them even if they don't specify any
> supplies because the regulator framework will insert dummy
> supplies as needed.
> 
> Cc: Nishanth Menon <nm@ti.com>
> Cc: Mark Brown <broonie@kernel.org>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

This patch only applies to net-next, please make that explicit in your
future submissions by saying something like "[PATCH net-next] ..."
in your Subject line.

Applied, thanks.

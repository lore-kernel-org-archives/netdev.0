From: Nishanth Menon <nm@ti.com>
Subject: Re: [PATCH] net: ks8851: Don't use regulator_get_optional()
Date: Thu, 29 May 2014 20:54:27 -0500
Message-ID: <CAGo_u6oH_LbZwjXoMziqZp5Wg3KfEcXE5Wg0Kcmqei1EPGivfg@mail.gmail.com>
References: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-arm-msm@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 28, 2014 at 3:11 PM, Stephen Boyd <sboyd@codeaurora.org> wrote:
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
> ---

Reviewed-and-Tested-by: Nishanth Menon <nm@ti.com>

SDP2430: with next-20140529:
before patch: https://github.com/nmenon/kernel-test-logs/blob/next-20140529/omap2plus_defconfig/sdp2430.txt

After patch: http://slexy.org/raw/s21sryFhAx
Looks good.
---
Regards,
Nishanth Menon

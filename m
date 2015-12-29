From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [RESEND PATCH v1 3/4] net: ethernet: arc: Add support emac for RK3036
Date: Wed, 30 Dec 2015 00:32:04 +0100
Message-ID: <10754282.l0GYzq0NWr@diego>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com> <1451287341-16453-4-git-send-email-zhengxing@rock-chips.com> <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Xing Zheng <zhengxing@rock-chips.com>,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>, keescook@google.com,
	leozwang@google.comi, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 29. Dezember 2015, 14:59:59 schrieb Florian Fainelli:
> On December 27, 2015 11:22:20 PM PST, Xing Zheng <zhengxing@rock-chips.com> 
wrote:
> >The RK3036's GRFs offset are different with RK3066/RK3188, and need to
> >set
> >mac TX/RX clock before probe emac.
> >
> >Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
> >---
> 
> <snip>
> 
> > };
> > 
> > static const struct of_device_id emac_rockchip_dt_ids[] = {
> >
> >-	{ .compatible = "rockchip,rk3066-emac", .data =
> >&emac_rockchip_dt_data[0] },
> >-	{ .compatible = "rockchip,rk3188-emac", .data =
> >&emac_rockchip_dt_data[1] },
> >+	{ .compatible = "rockchip,rk3036-emac", .data =
> >&emac_rockchip_dt_data[0] },
> >+	{ .compatible = "rockchip,rk3066-emac", .data =
> >&emac_rockchip_dt_data[1] },
> >+	{ .compatible = "rockchip,rk3188-emac", .data =
> >&emac_rockchip_dt_data[2] },
> >
> > 	{ /* Sentinel */ }
> 
> Food for thought, you might want to use an enum here to index
> emac_rockchip_dt_data which would be less error prone if you add/remove
> entries in this structure.

Or just have the structs separately and not in array-form at all, aka
rk3066_emac_dt_data, rk3036_emac_dt_data.

I don't think the original array really improves anything.

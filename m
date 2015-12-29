From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RESEND PATCH v1 3/4] net: ethernet: arc: Add support emac for RK3036
Date: Tue, 29 Dec 2015 14:59:59 -0800
Message-ID: <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com> <1451287341-16453-4-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: heiko@sntech.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>, keescook@google.com,
	leozwang@google.comi, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Xing Zheng <zhengxing@rock-chips.com>,
	linux-rockchip@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451287341-16453-4-git-send-email-zhengxing@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On December 27, 2015 11:22:20 PM PST, Xing Zheng <zhengxing@rock-chips.com> wrote:
>The RK3036's GRFs offset are different with RK3066/RK3188, and need to
>set
>mac TX/RX clock before probe emac.
>
>Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
>---
<snip>
> };
> 
> static const struct of_device_id emac_rockchip_dt_ids[] = {
>-	{ .compatible = "rockchip,rk3066-emac", .data =
>&emac_rockchip_dt_data[0] },
>-	{ .compatible = "rockchip,rk3188-emac", .data =
>&emac_rockchip_dt_data[1] },
>+	{ .compatible = "rockchip,rk3036-emac", .data =
>&emac_rockchip_dt_data[0] },
>+	{ .compatible = "rockchip,rk3066-emac", .data =
>&emac_rockchip_dt_data[1] },
>+	{ .compatible = "rockchip,rk3188-emac", .data =
>&emac_rockchip_dt_data[2] },
> 	{ /* Sentinel */ }

Food for thought, you might want to use an enum here to index emac_rockchip_dt_data which would be less error prone if you add/remove entries in this structure.

-- 
Florian

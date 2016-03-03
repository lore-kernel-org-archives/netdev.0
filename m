From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V3 2/4] net-next: mediatek: add support for MT7623
 ethernet
Date: Thu, 03 Mar 2016 13:06:55 -0800
Message-ID: <1457039215.4044.122.camel@perches.com>
References: <1457035361-57669-1-git-send-email-blogic@openwrt.org>
	 <1457035361-57669-3-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org,
	Steven Liu =?UTF-8?Q?=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	Carlos Huang =?UTF-8?Q?=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
	<Carlos.Huang@mediatek.com>, Felix Fietkau <nbd@openwrt.org>,
	Michael Lee <igvtee@gmail.com>
To: John Crispin <blogic@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457035361-57669-3-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-03 at 21:02 +0100, John Crispin wrote:
> Add ethernet support for MediaTek SoCs from the MT7623 family.
[]
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
[]
> +/* ugly macro hack to make sure hw_stats and ethtool strings are consistent */

I agree and think the _FE macros defines and uses should be removed.

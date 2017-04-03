From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 01/20] net: stmmac: export
 stmmac_set_mac_addr/stmmac_get_mac_addr
Date: Mon, 3 Apr 2017 14:39:03 +0200
Message-ID: <9514c077-1738-ea49-ca18-fbc46bac6144@st.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, <robh+dt@kernel.org>,
 <mark.rutland@arm.com>, <maxime.ripard@free-electrons.com>,
 <wens@csie.org>, <linux@armlinux.org.uk>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <alexandre.torgue@st.com>,
 Alexandre TORGUE <alexandre.torgue@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170403091444.29876-2-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Alex

do you can check if this has to be done for ST platforms?
I do not remember that it was necessary when build as module so
I cannot expect this should be only for dwmac-sun8i.

Regards
peppe



On 4/3/2017 11:14 AM, Corentin Labbe wrote:
> Thoses symbol will be needed for the dwmac-sun8i ethernet driver.
> For letting it to be build as module, they need to be exported.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> index 38f9430..67af0bd 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> @@ -248,6 +248,7 @@ void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
>   	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
>   	writel(data, ioaddr + low);
>   }
> +EXPORT_SYMBOL_GPL(stmmac_set_mac_addr);
>   
>   /* Enable disable MAC RX/TX */
>   void stmmac_set_mac(void __iomem *ioaddr, bool enable)
> @@ -279,4 +280,4 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
>   	addr[4] = hi_addr & 0xff;
>   	addr[5] = (hi_addr >> 8) & 0xff;
>   }
> -
> +EXPORT_SYMBOL_GPL(stmmac_get_mac_addr);

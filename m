From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 09/10] ARM: dts: berlin: add the Ethernet node
Date: Fri, 26 Sep 2014 21:25:12 +0400
Message-ID: <5425A178.4050501@cogentembedded.com>
References: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
 <1411742036-23520-10-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
 sebastian.hesselbarth@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1411742036-23520-10-git-send-email-antoine.tenart@free-electrons.com>
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

Hello.

On 09/26/2014 06:33 PM, Antoine Tenart wrote:

> This patch adds the Ethernet node, enabling the network unit on Berlin
> BG2Q SoCs.

> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> ---
>   arch/arm/boot/dts/berlin2q.dtsi | 17 +++++++++++++++++
>   1 file changed, 17 insertions(+)

> diff --git a/arch/arm/boot/dts/berlin2q.dtsi b/arch/arm/boot/dts/berlin2q.dtsi
> index 902eddb19cd8..d442b22fd1ea 100644
> --- a/arch/arm/boot/dts/berlin2q.dtsi
> +++ b/arch/arm/boot/dts/berlin2q.dtsi
> @@ -114,6 +114,23 @@
>   			#interrupt-cells = <3>;
>   		};
>
> +		eth0: ethernet@b90000 {
> +			compatible = "marvell,pxa168-eth";
> +			reg = <0xb90000 0x10000>;
> +			clocks = <&chip CLKID_GETH0>;
> +			interrupts = <GIC_SPI 24 IRQ_TYPE_LEVEL_HIGH>;
> +			/* set by bootloader */
> +			local-mac-address = [00 00 00 00 00 00];
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			phy-handle = <&ethphy0>;
> +			status = "disabled";
> +
> +			ethphy0: ethernet-phy@0 {
> +				reg = <0>;
> +			};
> +		};
> +

    Hm, is the PHY internal to the Ethernet controller?

WBR, Sergei

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 10/13] ARM: mvebu: add buffer manager nodes to
 armada-38x.dtsi
Date: Sun, 22 Nov 2015 12:41:34 +0300
Message-ID: <56518DCE.2010309@cogentembedded.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
 <1448178839-3541-11-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, myair@marvell.com, jaz@semihalf.com,
 simon.guinot@sequanux.org, xswang@marvell.com, nadavh@marvell.com,
 alior@marvell.com, tn@semihalf.com, gregory.clement@free-electrons.com,
 nitroshift@yahoo.com, davem@davemloft.net, sebastian.hesselbarth@gmail.com
To: Marcin Wojtas <mw@semihalf.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1448178839-3541-11-git-send-email-mw@semihalf.com>
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

On 11/22/2015 10:53 AM, Marcin Wojtas wrote:

> Armada 38x network controller supports hardware buffer management (BM).
> Since it is now enabled in mvneta driver, appropriate nodes can be added
> to armada-38x.dtsi - for the actual common BM unit (bm@c8000) and its
> internal SRAM (bm-bppi), which is used for indirect access to buffer
> pointer ring residing in DRAM.
>
> Pools - ports mapping, bm-bppi entry in 'soc' node's ranges and optional
> parameters are supposed to be set in board files.
>
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> ---
>   arch/arm/boot/dts/armada-38x.dtsi | 18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)
>
> diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
> index b7868b2..b9f4ce2 100644
> --- a/arch/arm/boot/dts/armada-38x.dtsi
> +++ b/arch/arm/boot/dts/armada-38x.dtsi
> @@ -539,6 +539,14 @@
>   				status = "disabled";
>   			};
>
> +			bm: bm@c8000 {

    The ePAPR standard tells us to give generic names to the device nodes, 
hence this should be named "buffer-manager" (?).

[...]
> @@ -617,6 +625,16 @@
>   			#size-cells = <1>;
>   			ranges = <0 MBUS_ID(0x09, 0x15) 0 0x800>;
>   		};
> +
> +		bm_bppi: bm-bppi {

    And this one "memory" (?).

[...]

MBR, Sergei

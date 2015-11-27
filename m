From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v3 net 6/6] net: mvneta: enable IP checksum with jumbo frames for Armada 38x on Port0
Date: Fri, 27 Nov 2015 17:29:18 +0100
Message-ID: <87y4dj76e9.fsf@free-electrons.com>
References: <1448639066-13074-1-git-send-email-mw@semihalf.com>
	<1448639066-13074-7-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448639066-13074-7-git-send-email-mw@semihalf.com> (Marcin
	Wojtas's message of "Fri, 27 Nov 2015 16:44:26 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On ven., nov. 27 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> The Ethernet controller found in the Armada 38x SoC's family support
> TCP/IP checksumming with frame sizes larger than 1600 bytes, however
> only on port 0.
>
> This commit enables it by setting 'tx-csum-limit' to 9800B in
> 'ethernet@70000' node.
>
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> ---
>  arch/arm/boot/dts/armada-38x.dtsi | 1 +

This commit should not be merged through the network subsystem but
through mvebu and then arm-soc.

Indeed we tried to centralize all the dts change in only one subsystem
to reduce the merge conflict.

Could you rename it in "mvebu: dts: enable IP checksum with jumbo frames
for Armada 38x on Port0" ?

I will applied on in mvebu/dts as soon as the network part will be
applied.

Thanks,

Gregory


>  1 file changed, 1 insertion(+)
>
> diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
> index c6a0e9d..e8b7f67 100644
> --- a/arch/arm/boot/dts/armada-38x.dtsi
> +++ b/arch/arm/boot/dts/armada-38x.dtsi
> @@ -498,6 +498,7 @@
>  				reg = <0x70000 0x4000>;
>  				interrupts-extended = <&mpic 8>;
>  				clocks = <&gateclk 4>;
> +				tx-csum-limit = <9800>;
>  				status = "disabled";
>  			};
>  
> -- 
> 1.8.3.1
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

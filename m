From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 09:52:07 -0500
Message-ID: <97251371-2772-42A5-A959-D9F7A8D0A65B@kernel.crashing.org>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
	<1312901031-29887-6-git-send-email-holt@sgi.com>
	<4E4179CB.6030101@freescale.com> <20110809184524.GB4926@sgi.com>
	<4E4186BD.5000602@freescale.com> <4E418F2D.4060504@grandegger.com>
	<4E419180.3090507@freescale.com> <20110809205900.GC4926@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110809205900.GC4926-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


On Aug 9, 2011, at 3:59 PM, Robin Holt wrote:

> I guess my poor wording may have gotten me in trouble.  I am getting
> ready to repost this patch, but I want to ensure I am getting it as
> right as possible.
> 
> I think I should reword the commit message to indicate we are removing
> the Documentation/.../fsl-flexcan.txt file which has essentially become
> empty and change the p1010si.dtsi file's can nodes to "fsl,p1010-flexcan",
> "fsl,flexcan".  Is that correct?
> 
> Thanks,
> Robin

This is wrong.  Again, what binding covers "fsl,flexcan" if you remove fsl-flexcan.txt:

[galak@right powerpc]$ git grep flexcan Documentation/devicetree/bindings
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:fsl,flexcan-v1.0 nodes
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:- fsl,flexcan-clock-source : CAN Engine Clock Source.This property selects
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:- fsl,flexcan-clock-divider : for the reference and system clock, an additional
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:      - v1.0 of flexcan-v1.0 represent the IP block version for P1010 SOC.
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:              compatible = "fsl,flexcan-v1.0";
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:              fsl,flexcan-clock-source = "platform";
Documentation/devicetree/bindings/net/can/fsl-flexcan.txt:              fsl,flexcan-clock-divider = <2>;

Not seeing anything that covers it.

I think the issue should be resolved by patching fsl-flexcan.txt to remove wording or update it.

- k

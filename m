From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Tue, 9 Aug 2011 08:50:02 -0500
Message-ID: <20110809135002.GW4926@sgi.com>
References: <4E403097.4020306@pengutronix.de>
	<9C64B7751C3BCA41B64A68E23005A7BE1B9D6C@039-SN1MPN1-002.039d.mgd.msft.net>
	<4E40F09F.60305@grandegger.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1BDF8C@039-SN1MPN1-004.039d.mgd.msft.net>
	<4E41108F.1090104@grandegger.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C3552@039-SN1MPN1-002.039d.mgd.msft.net>
	<20110809124919.GS4926@sgi.com> <4E413036.5080207@grandegger.com>
	<20110809133531.GV4926@sgi.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C4746@039-SN1MPN1-002.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9C64B7751C3BCA41B64A68E23005A7BE1C4746-TcFNo7jSaXPiTqIcKZ1S2K4g8xLGJsHaLnY5E4hWTkheoWH0uzbU5w@public.gmane.org>
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

On Tue, Aug 09, 2011 at 01:44:16PM +0000, U Bhaskar-B22300 wrote:
> 
> 
> > -----Original Message-----
> > From: Robin Holt [mailto:holt-sJ/iWh9BUns@public.gmane.org]
> > Sent: Tuesday, August 09, 2011 7:06 PM
> > To: Wolfgang Grandegger
> > Cc: Robin Holt; U Bhaskar-B22300; socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org;
> > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; Marc Kleine-
> > Budde
> > Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
> > 
> > On Tue, Aug 09, 2011 at 03:03:50PM +0200, Wolfgang Grandegger wrote:
> > > On 08/09/2011 02:49 PM, Robin Holt wrote:
...
> > > > How would you like to change that?  Should I add it as part of this
> > > > patch, add another patch to the series, or let you take care of it?
> > > >
> > > > Also, I assume the uboot project will need to be changed as well to
> > > > reflect the corrected name.
> > >
> > > I think you should provide patches within this series to cleanup the
> > > obsolete stuff, dts and binding doc.
> > 
> > It reads to me that the binding doc now reduces just the required
> > properties.  Should I remove the file entirely?
> [Bhaskar] I think the binding doc should atleast be present with the required properties to give the clarity
>  	    about the CAN functionality
> 		can0@1c000 {
>                  compatible = "fsl,flexcan";
>                  reg = <0x1c000 0x1000>;
>                  interrupts = <48 0x2>;
>                  interrupt-parent = <&mpic>;
>                  clock-frequency = <fixed by u-boot>;
>          	}; 

I am not sure what clarity we get for it.  Here it is as a work in progress:


CAN Device Tree Bindings
------------------------
2011 Freescale Semiconductor, Inc.

fsl,flexcan nodes
-----------------------
Only the required compatible-, reg- and interrupt-properties are supported.

Examples:
	can0@1c000 {
		compatible = "fsl,flexcan";
		reg = <0x1c000 0x1000>;
		interrupts = <48 0x2>;
		interrupt-parent = <&mpic>;
	};

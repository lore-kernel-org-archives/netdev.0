From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 12:16:00 -0500
Message-ID: <20110810171600.GV4926@sgi.com>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<1312945564-6626-6-git-send-email-holt@sgi.com>
	<4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C6A21@039-SN1MPN1-002.039d.mgd.msft.net>
	<20110810160054.GT4926@sgi.com>
	<63306A24-3FBF-4DAA-A0B9-6005F56BB76F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wood Scott-B07421 <B07421-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <63306A24-3FBF-4DAA-A0B9-6005F56BB76F-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
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

On Wed, Aug 10, 2011 at 11:53:15AM -0500, Kumar Gala wrote:
> 
> On Aug 10, 2011, at 11:00 AM, Robin Holt wrote:
> 
> > On Wed, Aug 10, 2011 at 02:36:20PM +0000, U Bhaskar-B22300 wrote:
> >> 
> >> 
> >>> -----Original Message-----
> >>> From: Robin Holt [mailto:holt-sJ/iWh9BUns@public.gmane.org]
> >>> Sent: Wednesday, August 10, 2011 7:46 PM
> >>> To: Wolfgang Grandegger
> >>> Cc: Robin Holt; Marc Kleine-Budde; U Bhaskar-B22300; Wood Scott-B07421;
> >>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Kumar Gala; socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; PPC
> >>> list
> >>> Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree
> >>> binding.
> >>> 
> >>> On Wed, Aug 10, 2011 at 03:47:43PM +0200, Wolfgang Grandegger wrote:
> >>>> Hi Robin,
> >>>> 
> >>>> On 08/10/2011 05:06 AM, Robin Holt wrote:
> >>>>> In working with the socketcan developers, we have come to the
> >>>>> conclusion the Documentation...fsl-flexcan.txt device tree
> >>>>> documentation needs to be cleaned up.  The driver does not depend
> >>>>> upon any properties other
> >>>> 
> >>>> Your first sentence could be misleading. Please just describe what the
> >>>> patch does and why, something like:
> >>>> 
> >>>> "This patch cleans up the documentation of the device-tree binding for
> >>>> the Flexcan devices on Freescale's PowerPC and ARM cores. Extra
> >>>> properties are not needed as the frequency of the source clock is
> >>>> fixed..." and so on.
> >>> 
> >>> I borrowed heavily from your message. ;)
> >>> 
> >>>>> than the required properties so we are removing the file.
> >>>>> Additionally, the p1010*dts* files are not following the standard
> >>>>> for node naming in that they have a trailing -v1.0.
> >>>> 
> >>>>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> >>>>> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> >>>>> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> >>>>> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> >>>>> To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> >>>>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> >>>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> >>>>> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> >>>>> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> >>>>> ---
> >>>>> .../devicetree/bindings/net/can/fsl-flexcan.txt    |   61 ----------
> >>> ----------
> >>>>> arch/powerpc/boot/dts/p1010rdb.dts                 |    8 ---
> >>>>> arch/powerpc/boot/dts/p1010si.dtsi                 |    8 +-
> >>>>> 3 files changed, 4 insertions(+), 73 deletions(-)  delete mode
> >>>>> 100644 Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> >>>>> 
> >>>>> diff --git
> >>>>> a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> >>>>> b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> >>>>> deleted file mode 100644
> >>>>> index 1a729f0..0000000
> >>>>> --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> >>>>> +++ /dev/null
> >>>>> @@ -1,61 +0,0 @@
> >>>>> -CAN Device Tree Bindings
> >>>>> -------------------------
> >>>>> -2011 Freescale Semiconductor, Inc.
> >>>>> -
> >>>>> -fsl,flexcan-v1.0 nodes
> >>>>> ------------------------
> >>>>> -In addition to the required compatible-, reg- and
> >>>>> interrupt-properties, you can -also specify which clock source shall
> >>> be used for the controller.
> >>>>> -
> >>>>> -CPI Clock- Can Protocol Interface Clock
> >>>>> -	This CLK_SRC bit of CTRL(control register) selects the clock source
> >>> to
> >>>>> -	the CAN Protocol Interface(CPI) to be either the peripheral clock
> >>>>> -	(driven by the PLL) or the crystal oscillator clock. The selected
> >>> clock
> >>>>> -	is the one fed to the prescaler to generate the Serial Clock
> >>> (Sclock).
> >>>>> -	The PRESDIV field of CTRL(control register) controls a prescaler
> >>> that
> >>>>> -	generates the Serial Clock (Sclock), whose period defines the
> >>>>> -	time quantum used to compose the CAN waveform.
> >>>>> -
> >>>>> -Can Engine Clock Source
> >>>>> -	There are two sources for CAN clock
> >>>>> -	- Platform Clock  It represents the bus clock
> >>>>> -	- Oscillator Clock
> >>>>> -
> >>>>> -	Peripheral Clock (PLL)
> >>>>> -	--------------
> >>>>> -		     |
> >>>>> -		    ---------		      -------------
> >>>>> -		    |       |CPI Clock	      | Prescaler |       Sclock
> >>>>> -		    |       |---------------->| (1.. 256) |------------>
> >>>>> -		    ---------		      -------------
> >>>>> -                     |  |
> >>>>> -	--------------  ---------------------CLK_SRC
> >>>>> -	Oscillator Clock
> >>>>> -
> >>>>> -- fsl,flexcan-clock-source : CAN Engine Clock Source.This property
> >>> selects
> >>>>> -			     the peripheral clock. PLL clock is fed to the
> >>>>> -			     prescaler to generate the Serial Clock (Sclock).
> >>>>> -			     Valid values are "oscillator" and "platform"
> >>>>> -			     "oscillator": CAN engine clock source is
> >>> oscillator clock.
> >>>>> -			     "platform" The CAN engine clock source is the bus
> >>> clock
> >>>>> -		             (platform clock).
> >>>>> -
> >>>>> -- fsl,flexcan-clock-divider : for the reference and system clock, an
> >>> additional
> >>>>> -			      clock divider can be specified.
> >>>>> -- clock-frequency: frequency required to calculate the bitrate for
> >>> FlexCAN.
> >>>>> -
> >>>>> -Note:
> >>>>> -	- v1.0 of flexcan-v1.0 represent the IP block version for P1010
> >>> SOC.
> >>>>> -	- P1010 does not have oscillator as the Clock Source.So the default
> >>>>> -	  Clock Source is platform clock.
> >>>>> -Examples:
> >>>>> -
> >>>>> -	can0@1c000 {
> >>>>> -		compatible = "fsl,flexcan-v1.0";
> >>>>> -		reg = <0x1c000 0x1000>;
> >>>>> -		interrupts = <48 0x2>;
> >>>>> -		interrupt-parent = <&mpic>;
> >>>>> -		fsl,flexcan-clock-source = "platform";
> >>>>> -		fsl,flexcan-clock-divqider = <2>;
> >>>>> -		clock-frequency = <fixed by u-boot>;
> >>>>> -	};
> >>>> 
> >>>> Do we really want to drop the documentation for that binding. I think
> >>>> something like the following text would be still useful:
> >>>> 
> >>>> ------------------------
> >>>> Flexcan CAN contoller on Freescale's ARM and PowerPC processors
> >>>> 
> >>>> Required properties:
> >>>> 
> >>>> - compatible : Should be "fsl,flexcan" and optionally
> >>>>               "fsl,flexcan-<processor>"
> >>>> - reg : Offset and length of the register set for this device
> >>>> - interrupts : Interrupt tuple for this device
> >>>> 
> >>>> Example:
> >>>> 
> >>>>  can@1c000 {
> >>>>          compatible = "fsl,p1010-flexcan", "fsl,flexcan";
> >>>>          reg = <0x1c000 0x1000>;
> >>>>          interrupts = <48 0x2>;
> >>>>          interrupt-parent = <&mpic>;
> >>>>  };
> >>>> -------------------------
> >>> 
> >>> Done, except the
> >>>>          compatible = "fsl,p1010-flexcan", "fsl,flexcan";
> >>> 
> >>> line is
> >>> 	compatible = "fsl,flexcan", "fsl,flexcan-p1010";
> >>> 
> >>>> 
> >>>> What do you think?
> >>>> 
> >>>>> diff --git a/arch/powerpc/boot/dts/p1010rdb.dts
> >>>>> b/arch/powerpc/boot/dts/p1010rdb.dts
> >>>>> index 6b33b73..d6a0bb2 100644
> >>>>> --- a/arch/powerpc/boot/dts/p1010rdb.dts
> >>>>> +++ b/arch/powerpc/boot/dts/p1010rdb.dts
> >>>>> @@ -169,14 +169,6 @@
> >>>>> 			};
> >>>>> 		};
> >>>>> 
> >>>>> -		can0@1c000 {
> >>>>> -			fsl,flexcan-clock-source = "platform";
> >>>>> -		};
> >>>>> -
> >>>>> -		can1@1d000 {
> >>>>> -			fsl,flexcan-clock-source = "platform";
> >>>>> -		};
> >>>>> -
> >>>>> 		usb@22000 {
> >>>>> 			phy_type = "utmi";
> >>>>> 		};
> >>>>> diff --git a/arch/powerpc/boot/dts/p1010si.dtsi
> >>>>> b/arch/powerpc/boot/dts/p1010si.dtsi
> >>>>> index 7f51104..20c396d 100644
> >>>>> --- a/arch/powerpc/boot/dts/p1010si.dtsi
> >>>>> +++ b/arch/powerpc/boot/dts/p1010si.dtsi
> >>>>> @@ -141,19 +141,19 @@
> >>>>> 		};
> >>>>> 
> >>>>> 		can0@1c000 {
> >>>>> -			compatible = "fsl,flexcan-v1.0";
> >>>>> +			compatible = "fsl,p1010-flexcan",
> >>>>> +					"fsl,flexcan";
> >>>> 
> >>>> Does fit on one line.
> >>>> 
> >>>>> 			reg = <0x1c000 0x1000>;
> >>>>> 			interrupts = <48 0x2>;
> >>>>> 			interrupt-parent = <&mpic>;
> >>>>> -			fsl,flexcan-clock-divider = <2>;
> >>>>> 		};
> >>>>> 
> >>>>> 		can1@1d000 {
> >>>>> -			compatible = "fsl,flexcan-v1.0";
> >>>>> +			compatible = "fsl,p1010-flexcan",
> >>>>> +					"fsl,flexcan";
> >>>> 
> >>>> Ditto
> >>>> 
> >>>>> 			reg = <0x1d000 0x1000>;
> >>>>> 			interrupts = <61 0x2>;
> >>>>> 			interrupt-parent = <&mpic>;
> >>>>> -			fsl,flexcan-clock-divider = <2>;
> >>>>> 		};
> >>>>> 
> >>>>> 		L2: l2-cache-controller@20000 {
> >>>> 
> >>>> Please also correct the node names (not using the number suffix).
> >>> 
> >>> So the node names should be
> >>> 		can@1c000 {
> >>> 		can@1d000 {
> >>> correct?
> >>> 
> >> [Bhaskar] As there are two CAN controllers on P1010,So won't it be better
> >> 	    to distinguish it by can0 and can1 instead by simple "can" ?
> > 
> > It looks like the way to do that is to assign a label to those devices
> > and then associate the label with an alias.  I have no idea how that
> > works under the hood, but it is the way other files are set up.  Take a
> > look at arch/powerpc/boot/dts/bamboo.dts for how they define the serial
> > interfaces.
> > 
> > Grant or Wolfgang, is that the right way to handle the concern about
> > names or does it have no practical effect with the Linux kernel?
> 
> It has not effect.  The label is just if you need to reference it via some other means.

Does the alias have an effect?

Robin

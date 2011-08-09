From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Tue, 09 Aug 2011 15:03:50 +0200
Message-ID: <4E413036.5080207@grandegger.com>
References: <20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com>	<4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com>	<4E403097.4020306@pengutronix.de>	<9C64B7751C3BCA41B64A68E23005A7BE1B9D6C@039-SN1MPN1-002.039d.mgd.msft.net>	<4E40F09F.60305@grandegger.com>	<9C64B7751C3BCA41B64A68E23005A7BE1BDF8C@039-SN1MPN1-004.039d.mgd.msft.net>	<4E41108F.1090104@grandegger.com>	<9C64B7751C3BCA41B64A68E23005A7BE1C3552@039-SN1MPN1-002.039d.mgd.msft.net>
	<20110809124919.GS4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110809124919.GS4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/09/2011 02:49 PM, Robin Holt wrote:
> On Tue, Aug 09, 2011 at 12:41:39PM +0000, U Bhaskar-B22300 wrote:
>>
>>
>>> -----Original Message-----
>>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>>> Sent: Tuesday, August 09, 2011 4:19 PM
>>> To: U Bhaskar-B22300
>>> Cc: Marc Kleine-Budde; socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org;
>>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>>> Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
>>>
>>> On 08/09/2011 11:27 AM, U Bhaskar-B22300 wrote:
>>>>
>>>>
>>>>> -----Original Message-----
>>>>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>>>>> Sent: Tuesday, August 09, 2011 2:03 PM
>>>>> To: U Bhaskar-B22300
>>>>> Cc: Marc Kleine-Budde; socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org;
>>>>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>>>>> Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
>>>>>
>>>>> Hi Bhaskar,
>>>>>
>>>>> On 08/09/2011 09:57 AM, U Bhaskar-B22300 wrote:
>>>>>>
>>>>>>
>>>>>>> -----Original Message-----
>>>>>>> From: Marc Kleine-Budde [mailto:mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org]
>>>>>>> Sent: Tuesday, August 09, 2011 12:23 AM
>>>>>>> To: Wolfgang Grandegger
>>>>>>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; U
>>>>>>> Bhaskar- B22300
>>>>>>> Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
>>>>>>>
>>>>>>> On 08/08/2011 05:33 PM, Wolfgang Grandegger wrote:
>>>>>>>>> ACK - The device tree bindings as in mainline's Documentation is
>>>>>>>>> a
>>>>>>> mess.
>>>>>>>>> If the powerpc guys are happy with a clock interfaces based
>>>>>>>>> approach somewhere in arch/ppc, I'm more than happy to remove:
>>>>>>>>> - fsl,flexcan-clock-source (not implemented, even in the fsl
>>>>>>>>> driver)
>>>>>> [Bhaskar]I have pushed the FlexCAN series of patches, It contains
>>>>>> the usage of all the fields posted in the FlexCAN bindings at
>>>>>> http://git.kernel.org/?p=linux/kernel/git/stable/linux-3.0.y.git;a=b
>>>>>> lo
>>>>>> b;f=Documentation/devicetree/bindings/net/can/fsl-flexcan.txt;h=1a72
>>>>>> 9f
>>>>>> 089866259ef82d0db5893ff7a8c54d5ccf;hb=94ed5b4788a7cdbe68bc7cb8516972
>>>>>> cb
>>>>>> ebdc8274
>>>>>
>>>>> As Marc already pointed out, Robin already has a much more advanced
>>>>> patch stack in preparation. Especially your patches do not care about
>>>>> the already existing Flexcan core on the Freescale's ARM socks.
>>>> [Bhaskar] No, the patches are taking care of the existing ARM
>>> functionality.
>>>> 	I have not tested on the ARM based board, but the patches are made
>>> in a
>>>>       Manner that it should not break the ARM based functionality.
>>>>>
>>>>>>>>>
>>>>>>>>> - fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
>>>>>>>>> - clock-frequency           /   a single clock-frequency attribute
>>>>>>>>
>>>>>>>> In the "net-next-2.6" tree there is also:
>>>>>>>>
>>>>>>>>  $ grep flexcan arch/powerpc/boots/dts/*.dts
>>>>>>>>   p1010rdb.dts:			fsl,flexcan-clock-source =
>>>>> "platform";
>>>>>>>>   p1010rdb.dts:			fsl,flexcan-clock-source =
>>>>> "platform";
>>>>>>>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>>>>>>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>>>>>>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>>>>>>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>>>>>>>
>>>>>>>> Especially the fsl,flexcan-clock-divider = <2>; might make people
>>>>>>>> think, that they could set something else.
>>>>>>>
>>>>>> [Bhaskar] As it is mentioned in the Flexcan bindings, the need of
>>>>> fsl,flexcan-clock-divider = <2>;
>>>>>> 	    But I kept it as "2" because FlexCan clock source is the
>>>>> platform clock and it is CCB/2
>>>>>> 	    If the "2" is misleading, the bindings can be changed or some
>>>>> text can be written to make the meaning of "2"
>>>>>>           Understandable , Please suggest ..
>>>>>
>>>>> The clock source and frequency is fixed. Why do we need an extra
>>>>> properties for that. We have panned to remove these bogus bindings
>>>>> from the Linux kernel, which sneaked in *without* any review on the
>>>>> relevant mailing lists (at least I have not realized any posting). We
>>>>> do not think they are really needed. They just confuse the user. We
>>>>> also prefer to use the compatibility string "fsl,flexcan" instead
>>>>> "fsl,flexcan-v1.0". It's unusual to add a version number, which is
>>>>> for the Flexcan on the PowerPC cores only, I assume, but there will
>>>>> be device tree for ARM soon. A proper compatibility string would be
>>>>> "fsl,p1010-flexcan" if we really need to distinguish.
>>>>>
>>>> [Bhaskar] About clock source.. There can be two sources of clock for
>>> the CAN.
>>>> 	Oscillator or the platform clock, but at present only platform
>>> clock is supported
>>>> 	in P1010.If we remove the fsl,flexcan-clock-source property, we
>>> will lost the flexibility
>>>> 	of changing the clock source ..
>>>>
>>>>           About clock-frequency... it is also not fixed. It depends on
>>> the platform clock which in turns
>>>>           Depends on the CCB clock. So it will be better to keep clock-
>>> frequency property which is getting fixed via u-boot.
>>>
>>> The frequency is fixed to CCB-frequency / 2. Will that ever change? What
>>> can we expect from future Flexcan hardware? Will it support further clock
>>> sources?
>> [Bhaskar] Yes the frequency will always be CCB-frequency/2.Even if the CCB gets changed that will be taken care by the u-boot fixup code for
>> 	clock-frequency. clock-frequency is not filled by somebody in the dts file. It will be done by u-boot.
>> 	For clock source,I can't say right now, that's why I have kept a property for this in the can node. So that in future, we need to fill it 
>> 	appropriately
> 
> Speaking of the dts file, I have left the p1010si.dtsi file with
> the fsl,flexcan-v1.0 .compatible definition.  The flexcan folks
> (IIRC Wolfgang) objected to that as it does not follow the standard
> which should be just fsl,flexcan.
> 
> How would you like to change that?  Should I add it as part of this patch,
> add another patch to the series, or let you take care of it?
> 
> Also, I assume the uboot project will need to be changed as well to
> reflect the corrected name.

I think you should provide patches within this series to cleanup the
obsolete stuff, dts and binding doc.

Wolfgang.

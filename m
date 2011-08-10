From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 12:26:17 -0500
Message-ID: <37458316-F50D-4E4A-A59B-01CB8A6FC108@kernel.crashing.org>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<1312945564-6626-6-git-send-email-holt@sgi.com>
	<4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C6A21@039-SN1MPN1-002.039d.mgd.msft.net>
	<20110810160054.GT4926@sgi.com>
	<63306A24-3FBF-4DAA-A0B9-6005F56BB76F@kernel.crashing.org>
	<20110810171600.GV4926@sgi.com>
	<8C9817C6-735D-4B7C-A03B-5661C04C725A@kernel.crashing.org>
	<20110810172040.GX4926@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Wood Scott-B07421 <B07421-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110810172040.GX4926-sJ/iWh9BUns@public.gmane.org>
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

>>>>>>> So the node names should be
>>>>>>> 		can@1c000 {
>>>>>>> 		can@1d000 {
>>>>>>> correct?
>>>>>>> 
>>>>>> [Bhaskar] As there are two CAN controllers on P1010,So won't it be better
>>>>>> 	    to distinguish it by can0 and can1 instead by simple "can" ?
>>>>> 
>>>>> It looks like the way to do that is to assign a label to those devices
>>>>> and then associate the label with an alias.  I have no idea how that
>>>>> works under the hood, but it is the way other files are set up.  Take a
>>>>> look at arch/powerpc/boot/dts/bamboo.dts for how they define the serial
>>>>> interfaces.
>>>>> 
>>>>> Grant or Wolfgang, is that the right way to handle the concern about
>>>>> names or does it have no practical effect with the Linux kernel?
>>>> 
>>>> It has not effect.  The label is just if you need to reference it via some other means.
>>> 
>>> Does the alias have an effect?
>> 
>> nope
> 
> Then how does the device number get associated with a particular device

What do you mean by device number?

> and how is user-space ensured a consistent namespace?

that is left to udev rules.

- k

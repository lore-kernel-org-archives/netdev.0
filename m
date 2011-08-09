From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Tue, 09 Aug 2011 15:19:27 +0200
Message-ID: <4E4133DF.5040405@grandegger.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com> <4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com> <4E403097.4020306@pengutronix.de>
	<9C64B7751C3BCA41B64A68E23005A7BE1B9D6C@039-SN1MPN1-002.039d.mgd.msft.net>
	<4E40F09F.60305@grandegger.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1BDF8C@039-SN1MPN1-004.039d.mgd.msft.net>
	<4E41108F.1090104@grandegger.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C3552@039-SN1MPN1-002.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <9C64B7751C3BCA41B64A68E23005A7BE1C3552-TcFNo7jSaXPiTqIcKZ1S2K4g8xLGJsHaLnY5E4hWTkheoWH0uzbU5w@public.gmane.org>
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

On 08/09/2011 02:41 PM, U Bhaskar-B22300 wrote:
> 
> 
>> -----Original Message-----
>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
...
>> The frequency is fixed to CCB-frequency / 2. Will that ever change? What
>> can we expect from future Flexcan hardware? Will it support further clock
>> sources?
> [Bhaskar] Yes the frequency will always be CCB-frequency/2.Even if the CCB gets changed that will be taken care by the u-boot fixup code for
> 	clock-frequency. clock-frequency is not filled by somebody in the dts file. It will be done by u-boot.

U-Boot fills in "clock_freq", anyway...

> 	For clock source,I can't say right now, that's why I have kept a property for this in the can node. So that in future, we need to fill it 
> 	appropriately

This just confirms that we currently can live without clock-frequency,
clock-source and clock-divider properties. If it's really required
sometime in the future, we can add it, I think.

Wolfgang.

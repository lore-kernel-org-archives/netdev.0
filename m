From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 16:16:27 +0200
Message-ID: <4E3FEFBB.9050103@grandegger.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>
	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>
	<20110808135630.GU4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808135630.GU4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/08/2011 03:56 PM, Robin Holt wrote:
>> commit 65bb8b060a873fa4f5188f2951081f6011259614
>> Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> Date:   Fri Mar 4 20:27:58 2011 +0530
> 
> On a side note, that commit fixes up "fsl,flexcan-v1.0"
> ...
> +       do_fixup_by_compat_u32(blob, "fsl,flexcan-v1.0",
> +                       "clock_freq", gd->bus_clk, 1);
> 
> Should I go back to flexcan-v1.0 in my patches?

Well, no. Let's wait. I don't think we need it. Also, it sets
"clock_freq" while

 http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt

documents "clock-frequencies"... :-(.

Wolfgang,

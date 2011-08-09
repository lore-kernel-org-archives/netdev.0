From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 09 Aug 2011 17:10:32 +0200
Message-ID: <4E414DE8.4050909@grandegger.com>
References: <1312892907-20419-1-git-send-email-holt@sgi.com>
	<1312892907-20419-5-git-send-email-holt@sgi.com>
	<9C64B7751C3BCA41B64A68E23005A7BE1C4A88@039-SN1MPN1-002.039d.mgd.msft.net>
	<20110809145507.GY4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110809145507.GY4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/09/2011 04:55 PM, Robin Holt wrote:
> On Tue, Aug 09, 2011 at 02:45:58PM +0000, U Bhaskar-B22300 wrote:
>> Hi Robin,
>> 	Where are you doing the irq handling ie request_irq() for the powerpc based P1010.
>> 	Or the existing code of ARM based FlexCAN will work for P1010 ??
> 
> It appears that the of_device stuff got moved under the struct device
> and that allows the request_irq() to just magically work.

Cool! Actually I was also missing of_address_to_resource (or of_iomap)
and irq_of_parse_and_map(). But the resources seem to be filled in here:

  http://lxr.linux.no/#linux+v3.0.1/drivers/of/platform.c#L121

Wolfgang.

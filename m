From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/4] drivers/net/can/mscan/mpc5xxx_can.c: Add
	of_node_put to avoid memory leak
Date: Wed, 01 Sep 2010 10:59:55 -0700 (PDT)
Message-ID: <20100901.105955.176668287.davem@davemloft.net>
References: <Pine.LNX.4.64.1008311943280.2668@ask.diku.dk>
	<20100831191014.GA9603@pengutronix.de>
	<4C7D565F.307@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org, julia-dAYI7NvHqcQ@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C7D565F.307-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Date: Tue, 31 Aug 2010 21:22:07 +0200

> On 08/31/2010 09:10 PM, Wolfram Sang wrote:
>> On Tue, Aug 31, 2010 at 07:44:00PM +0200, Julia Lawall wrote:
>>> Add a call to of_node_put in the error handling code following a call to
>>> of_find_matching_node.
>>>
>>> This patch also moves the existing call to of_node_put after the call to
>>> iounmap in the error handling code, to make it possible to jump to
>>> of_node_put without doing iounmap.  These appear to be disjoint operations,
>>> so the ordering doesn't matter.
>>>
>>> This patch furthermore changes the -ENODEV result in the error handling
>>> code for of_find_matching_node to a return of 0, as found in the error
>>> handling code for of_iomap, because the return type of the function is
>>> unsigned.
>>>
>>> The semantic match that finds this problem is as follows:
>>> (http://coccinelle.lip6.fr/)
 ...
>>> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
>> 
>> Reviewed-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> 
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Applied.

From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: fix WARN_ON dump in
	net/core/rtnetlink.c:rtmsg_ifinfo()
Date: Tue, 10 Nov 2009 20:45:35 +0100
Message-ID: <4AF9C2DF.3020304@grandegger.com>
References: <4AF54389.1090309@grandegger.com>
	<20091108.004602.213063654.davem@davemloft.net>
	<4AF68FCB.4050103@grandegger.com> <4AF94D74.4040606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4AF94D74.4040606-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Wolfgang Grandegger wrote:
>> David Miller wrote:
>>> From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>> Date: Sat, 07 Nov 2009 10:53:13 +0100
>>>
>>>> On older kernels, e.g. 2.6.27, a WARN_ON dump in rtmsg_ifinfo()
>>>> is thrown when the CAN device is registered due to insufficient
>>>> skb space, as reported by various users. This patch adds the
>>>> rtnl_link_ops "get_size" to fix the problem. I think this patch
>>>> is required for more recent kernels as well, even if no WARN_ON
>>>> dumps are triggered. Maybe we also need "get_xstats_size" for
>>>> the CAN xstats.
>>>>
>>>> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>> Applied to net-2.6, thanks Wolfgang.
>> Thanks, the commit message included some questions. What is the rule
>> using the rtnl_link_ops "get_size" or "get_xstats_size". Are these
>> mandatory if the corresponding fill functions are used?
> 
> Yes. You also need a get_xstats_size() function.

Thanks for clarification. I will provide a patch a.s.a.p.

Wolfgang.

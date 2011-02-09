From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH -next] can: softing_cs needs slab.h
Date: Wed, 09 Feb 2011 12:43:53 -0800 (PST)
Message-ID: <20110209.124353.104047600.davem@davemloft.net>
References: <20110209170225.94eae681.sfr@canb.auug.org.au>
	<20110209084456.802370fa.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: randy.dunlap-veTT2BtV2gBXrIkS9f7CXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110209084456.802370fa.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

From: Randy Dunlap <randy.dunlap-veTT2BtV2gBXrIkS9f7CXA@public.gmane.org>
Date: Wed, 9 Feb 2011 08:44:56 -0800

> From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> 
> softing_cs.c uses kzalloc & kfree, so it needs to include linux/slab.h.
> 
> drivers/net/can/softing/softing_cs.c:234: error: implicit declaration of function 'kfree'
> drivers/net/can/softing/softing_cs.c:271: error: implicit declaration of function 'kzalloc'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Applied, thanks Randy.

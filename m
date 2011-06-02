From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Thu, 02 Jun 2011 00:10:59 -0700 (PDT)
Message-ID: <20110602.001059.183111215741236866.davem@davemloft.net>
References: <Pine.LNX.4.64.1106012207260.5871@ask.diku.dk>
	<20110601.131136.391831410750786951.davem@davemloft.net>
	<Pine.LNX.4.64.1106020748020.22932@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, wharms-fPG8STNUNVg@public.gmane.org
To: julia-dAYI7NvHqcQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1106020748020.22932-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
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

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Date: Thu, 2 Jun 2011 07:48:50 +0200 (CEST)

> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> The failed_get label is used after the call to clk_get has succeeded, so it
> should be moved up above the call to clk_put.
> 
> The failed_req labels doesn't do anything different than failed_get, so
> delete it.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Applied.

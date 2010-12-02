From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 05/20] can: EG20T PCH: Delete
	unnecessary spin_lock
Date: Thu, 02 Dec 2010 13:14:02 -0800 (PST)
Message-ID: <20101202.131402.102554930.davem@davemloft.net>
References: <4CF47B68.4050405@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CF47B68.4050405-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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

From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Date: Tue, 30 Nov 2010 13:19:52 +0900

> Delete unnecessary spin_lock for accessing Message Object.
> Since all message objects are divided into tx/rx area completely,
> spin_lock processing is unnecessary.
> 
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Applied.

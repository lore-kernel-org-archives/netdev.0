From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3] can: mcp251x: Move to threaded
	interrupts instead of workqueues.
Date: Wed, 03 Feb 2010 20:33:16 -0800 (PST)
Message-ID: <20100203.203316.174240016.davem@davemloft.net>
References: <cabda6421002030939w3788a40en38955d31dd765583@mail.gmail.com>
	<1265218794-25808-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: chripell-VaTbYqLCNhc@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1265218794-25808-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
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

From: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Date: Wed,  3 Feb 2010 18:39:54 +0100

> This patch addresses concerns about efficiency of handling incoming
> packets. Handling of interrupts is done in a threaded interrupt handler
> which has a smaller latency than workqueues. This change needed a rework
> of the locking scheme that was much simplified. Some other (more or less
> longstanding) bugs are fixed: utilization of just half of the RX
> buffers, useless wait for interrupt on open, more reliable reset
> sequence. The MERR interrupt is not used anymore: it overloads the CPU
> in error-passive state without any additional information. One shot mode
> is disabled because it's not clear if it can be handled efficiently on
> this CAN controller.
> 
> Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>

Applied.

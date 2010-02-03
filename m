From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Wed, 3 Feb 2010 18:39:48 +0100
Message-ID: <cabda6421002030939w3788a40en38955d31dd765583@mail.gmail.com>
References: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com>
	<1264959793-1797-1-git-send-email-chripell@fsfe.org>
	<4B67F7B3.8060509@grandegger.com>
	<cabda6421002022323m6ea676afu6c73843280b75e24@mail.gmail.com>
	<4B692A8D.2040000@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B692A8D.2040000-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Wed, Feb 3, 2010 at 8:49 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>
> CAN experts told me/us, that the bus-errors might be important
> information for an apps. I just started a thread on how to improve our
> current bus-error handling implementation.
>

OK, I'll follow that thread to see how can additional error
information be exported to user space efficiently. For now I'm
sending, in reply to this email, the v3 patch that disables one shot
mode too as was discussed in the socketcan ml. There are some
important bug fixes in it so I hope it could be approved before next
merge window.

-- 
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."

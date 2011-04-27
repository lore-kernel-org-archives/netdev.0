From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH v4 0/5] CAN: add SAE J1939 protocol
Date: Wed, 27 Apr 2011 10:53:30 +0200
Message-ID: <20110427085330.GA757@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
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

This series adds SAE J1939 support to the current net-next-2.6.

1/5: can: extend sockaddr_can to include j1939 members
2/5: can: add rtnetlink support
3/5: j1939: initial import of SAE J1939
4/5: j1939: add documentation & MAINTAINERS
5/5: iproute2: use CAN & J1939

Differences from v3:
* Address claiming does not need a state machine anymore
* Dropped a per-ECU lock.
* Tasklets fill the gap between hrtimer (hardirq context)
  and networking (softirq context), without needing
  spin_lock_irqsave() & friends.
* Added example sendto() code in documentation

Differences from v2:
* replace magic constants with macro's
* use a static protocol stack, not a dynamic one.
* remove feature that have limited use and are
  difficult to explain.
* renamed some structure types to increase code readability.
* block on transport sessions until CAN frame is queued.

Kind regards,
Kurt Van Dijck

From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 0/6] CAN: add SAE J1939 protocol
Date: Tue, 15 Mar 2011 10:23:41 +0100
Message-ID: <20110315092341.GA332@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110314132004.GA333-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

On Mon, Mar 14, 2011 at 02:20:04PM +0100, Kurt Van Dijck wrote:
> 
> This series adds SAE J1939 support to the current net-next-2.6.
> For the rtnetlink operations to work, a 2.6.38-rc1 is required.
> 
> 1/6: can: extend sockaddr_can to include j1939 members
> 2/6: can: add rtnetlink support
> 3/6: can: make struct proto const
> 4/6: j1939: initial import of SAE J1939
> 5/6: j1939: add documentation & MAINTAINERS
> 6/6: iproute2: use CAN & J1939
> 
> Still a lot of things probably need explanation...

I had not mentioned the major differences with v2
(which went to berlios SocketCAN mailing list only).

* replace magic constants with macro's
* use a static protocol stack, not a dynamic one.
* remove feature that have limited use and are
  difficult to explain.
* renamed some structure types to increase code readability. 
* block on transport sessions until CAN frame is queued.

* fix bugs.

Kurt

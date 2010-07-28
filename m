From: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Subject: can: expected receive behavior broken
Date: Wed, 28 Jul 2010 09:56:38 +0200
Message-ID: <201007280956.38957.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

Hi,

I just noticed that the receive behavior of CAN sockets is broken
in current net-next-2.6.
I wrote some simple code that receives messages and echos them back to
the bus. When I now trigger one single message on the bus, I get
this message received and echoed back in an endless loop.

I do not touch the sockopts CAN_RAW_LOOPBACK or CAN_RAW_RECV_OWN_MSGS in my code.
Only (!) setting CAN_RAW_LOOPBACK to 0 helps at the moment. But this behavior
actually has nothing to do with LOOPBACK but more with RECV_OWN_MSGS.

Matthias

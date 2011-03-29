From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: SAE J1939: update
Date: Tue, 29 Mar 2011 16:29:07 +0200
Message-ID: <20110329142907.GB335@kurt.e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D8623BE.2080807-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

Oliver,

Some progress:

I dropped the state-machine for the address claiming. This makes it less
confusing I hope.

I dropped SO_J1939_DEST_MASK. This could be done in userspace by
accessing a procfs file, or additional rtnetlink ...
Lookup up remote ecu's is not strictly necessary in kernel.
I have no idea yet how such library would look like.

Can userspace tools be attached to the socketCAN subversion can-utils, or
would a seperate dir be necessary?

I'd say 'suggestions are welcome' but I know you'd suggest to remove
address claiming..

Kurt

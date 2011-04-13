From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Wed, 13 Apr 2011 06:49:28 +0200
Message-ID: <20110413044928.GA289@kurt.e-circ.dyndns.org>
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

Oliver et.al.,

On Sun, Mar 20, 2011 at 04:56:46PM +0100, Oliver Hartkopp wrote:
> On 14.03.2011 14:59, Kurt Van Dijck wrote:
> 
> Then you suggest to attach static and/or dynamic addresses to the interface.
> 
> > +  Assigning addresses is done via
> > +  $ ip addr add dev canX j1939 0xXX
> > +  statically or
> > +  $ ip addr add dev canX j1939 name 0xXX
> > +  dynamically. In the latter case, address claiming must take place
> > +  before other traffic can leave.
> 
> like you would have using DHCP/DNS (adapted for j1939) ...
> 
I suspect the confustion with DHCP/DNS comes free with the used terminology.

Specifications talk about a 64bit NAME, where is actually is a 64bit UUID.
Calling this number a UUID may clarify things, but leaves the spec in the
terminology.

one would then do:
$ ip addr add dev canX j1939 uuid XXXX

Would that be a good way to progress?

Kurt

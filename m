From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v4 2/5] can: add rtnetlink support
Date: Wed, 4 May 2011 06:20:47 +0200
Message-ID: <20110504042047.GB278@e-circ.dyndns.org>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org>
	<20110427085705.GC757@kurt.e-circ.dyndns.org>
	<4DBD9586.7080908@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DBD9586.7080908-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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


> Besides some minor adaptions to support the SVN i left out some infrastructure
> changes you made in patch 2/5 to constify this ...
> 
> > -static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
> > +static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
> 
> and this ...
> 
> > -static struct can_proto *can_try_module_get(int protocol)
> > +static const struct can_proto *can_try_module_get(int protocol)
> 
> (..)
> 
> > +static inline void can_put_proto(const struct can_proto *cp)
> > +{
> > +	module_put(cp->prot->owner);
> > +}
> 
> These infrastructure changes did not really belong to the rtnetlink support.

I see. I see I've made a mistake in the patch set here.
I'll go for a seperate 'make it const' patch.

Thanks,
Kurt

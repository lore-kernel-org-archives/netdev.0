From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 1/6] can: extend sockaddr_can to include j1939 members
Date: Mon, 14 Mar 2011 15:53:56 +0100
Message-ID: <20110314145356.GI333@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314132409.GB333@e-circ.dyndns.org>
	<1300112100.3423.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1300112100.3423.24.camel@edumazet-laptop>
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

On Mon, Mar 14, 2011 at 03:15:00PM +0100, Eric Dumazet wrote:
> > +/*
> > + * required_size
> > + * macro to find the minimum size of a struct
> > + * that includes a requested member
> > + */
> > +#define required_size(member, struct_type) \
> > +	(offsetof(typeof(struct_type), member) + \
> > +	 sizeof(((typeof(struct_type) *)(0))->member))
> > +
> 
> Hmm, most similar macros reverse arguments.
> 
> (For example : offsetof())
I had 'list_entry' in mind.
> 
> What about
> 
> #define required_size(TYPE, MEMBER) ...
I'm not against that ...
If I receive no complaint for that, I can alter this in the next series.
> 
> 
Thanks,
Kurt

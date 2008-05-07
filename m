From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 7 May 2008 15:48:06 +0200
Message-ID: <200805071548.06693.mb@bu3sch.de>
References: <20080430124055.091382000@sipsolutions.net> <1210161133.5642.19.camel@johannes.berg> <20080507130548.GA26977@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080507130548.GA26977-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 May 2008 15:05:48 Herbert Xu wrote:
> On Wed, May 07, 2008 at 01:52:13PM +0200, Johannes Berg wrote:
> >
> > Hmm. Why does busy exist then? Historical accident? I really really
> 
> Yes it's historical baggage.  These days the biggest users would
> be LLTX drivers which should all be converted to non-LLTX and
> drivers that don't keep track of queue status properly.

So there's no way to actually fail in a TX handler? Drivers
are doomed to drop the packet, if they cannot handle it due to
ring overflow?

-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

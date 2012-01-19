From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 4/5] SUNRPC: ip map cache per network namespace cleanup
Date: Thu, 19 Jan 2012 17:21:01 -0500
Message-ID: <20120119222101.GA4929@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
 <20120119144931.9957.78601.stgit@localhost6.localdomain6>
 <20120119163722.GE527@fieldses.org>
 <4F184E70.5070902@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F184E70.5070902-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2012 at 09:10:08PM +0400, Stanislav Kinsbursky wrote:
> 19.01.2012 20:37, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >On Thu, Jan 19, 2012 at 06:49:31PM +0400, Stanislav Kinsbursky wrote=
:
> >>This patch converts ip_map_cache per network namespace implemenetat=
ion to the
> >>same view, as other caches done in the series.
> >>Besides generalization, code becomes shorter with this patch.
> >
> >Again, isnt' it ip_map_cache, and not one of the dynamically created
> >cache details, that's being passed to the lookup routines?
> >
> >I may just be confused....
> >
>=20
> Nope. ip_map_cache was made per network namespace a long time ago.
> But it was done in other way: no static templates - just allocation
> and initialization.
> But static template looks clearer to me. So I've used this approach
> for other caches. And decided to update ip_map_cache management in
> the same way.

Going and reading the code.... OK, I see what you mean, makes sense.
Thanks!

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

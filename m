From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/4] SUNRPC: use passed network namespace context in
 rpc_parse_scope_id()
Date: Mon, 12 Dec 2011 11:07:22 -0500
Message-ID: <20111212160722.GF18185@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
 <20111207112016.17273.44510.stgit@localhost6.localdomain6>
 <20111208204749.GC32505@fieldses.org>
 <4EE625E1.7000502@parallels.com>
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
In-Reply-To: <4EE625E1.7000502-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2011 at 08:03:45PM +0400, Stanislav Kinsbursky wrote:
> 09.12.2011 00:47, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >On Wed, Dec 07, 2011 at 03:20:16PM +0300, Stanislav Kinsbursky wrote=
:
> >>Use incomming network context in rpc_parse_scope_id() instead of ha=
rd-coded
> >
> >Changelogs are a little confusing; I might have said "allow
> >rpc_parse_cope_id() caller to pass in network context instead of usi=
ng
> >hard-code "init_net"."
>=20
> Probably, you variant is better. My English is not good enough to
> write descriptive and, in the same time, clear and short comments to
> patches.

Uh, and mine's got a problm or two as well.  ("hard-code" should be
"hard-coded" in the above.)

My main complaint was just that "incoming network context" sounds like
it refers to the network context associated with an incoming rpc
request.  But actually all you're doing is using the network context
passed in by the caller.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

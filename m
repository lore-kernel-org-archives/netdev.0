From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
Date: Mon, 12 Dec 2011 11:15:42 -0500
Message-ID: <20111212161542.GH18185@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
 <20111208204648.GB32505@fieldses.org>
 <4EE62824.9090807@parallels.com>
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
In-Reply-To: <4EE62824.9090807-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2011 at 08:13:24PM +0400, Stanislav Kinsbursky wrote:
> 09.12.2011 00:46, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote=
:
> >>This is another precursor patch set aimed to remove hard-coded "ini=
t_net"
> >>reference from SUNRPC sockaddr convertion and construction routines=
=2E
> >
> >ACK--all look straightforward.  (Only complaint would be that this i=
sn't
> >terribly interesting till we see how these are used.)
> >
>=20
> Actually, all is simple. These init_net pointers will be replaced
> later by "transports, clients and others" network namespace
> contexts.
> I have some more patches for NFS layer. But I don't see any sense to
> sent them now since no "virtualization" patches were commited yet.
> So, currently, I'm trying to finalize "SUNRPC per network namespace"
> task, and soon I'll send a patch set making SUNRPC sysctl's
> network-namespace-aware. It is a little bit tricky and ugly from my
> pow, so any ideas are welcome.

No ideas.... What's the ugly part?

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

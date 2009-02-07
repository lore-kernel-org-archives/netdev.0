From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sat, 07 Feb 2009 11:23:24 -0500
Message-ID: <1234023804.17241.14.camel@heimdal.trondhjem.org>
References: <20090206.140714.201930500.davem@davemloft.net>
	 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
	 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
	 <20090206.192243.47948705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org, chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, trond-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090206.192243.47948705.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-02-06 at 19:22 -0800, David Miller wrote:
> From: "Ilpo J=C3=A4rvinen" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
> Date: Sat, 7 Feb 2009 00:58:44 +0200 (EET)
>=20
> > I think your "English" is too strict requirement.
>=20
> I absolutely and whole-heartedly agree.  This set of
> requirements is beyond rediculious and will do nothing
> but deter people from contributing.
>=20
> So unless that's what the goal is...
>=20
> Anyways, I'll be applying Ilpo's great changes to the
> net-next-2.6 GIT tree, without putting him through the
> ringer like this.

No. I find it quite unacceptable for the networking group to circumvent
the standard Linux review process in this manner. If you plan to push a
patch into the sunrpc code against the wishes of the community and
people that maintain that code then I'll be petitioning Linus to revert
it on general principle as soon as it hits his tree.

Like it or not, the changelog _is_ a part of the patch that is subject
to review and comment, and while I like the rest of the patch, I will
support Chuck and Bruce's comments that putting a bunch of diffstat
output into the changelog is not a substitute for a simple sentence. Al=
l
it takes is

"
Save 147 lines by moving the common code from xs_udp_write_space() and
xs_tcp_write_space() into a separate helper.

S-o-b: Ilpo....
"

and everyone will be happy. So please stop making a storm in a teacup
out of this...

Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

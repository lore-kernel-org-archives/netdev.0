From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPV6 routing problem
Date: Fri, 24 Jan 2014 14:59:32 +0100
Message-ID: <20140124135932.GR7269@order.stressinduktion.org>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com> <20140122070759.GB28225@order.stressinduktion.org> <20140122071101.GC28225@order.stressinduktion.org> <CAJzFV34FhudmwOPY1q9SUtagb8rUuQanrAqt_+cOyETFsLcxqw@mail.gmail.com> <CD36411A-7584-48B1-A406-E1584B3D32DD@sekil.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sharat Masetty <sharat04@gmail.com>, netdev@vger.kernel.org
To: Emmanuel Thierry <ml@sekil.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34645 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbaAXN7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 08:59:34 -0500
Content-Disposition: inline
In-Reply-To: <CD36411A-7584-48B1-A406-E1584B3D32DD@sekil.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 10:36:54AM +0100, Emmanuel Thierry wrote:
> Hello,
>=20
> Le 23 janv. 2014 =C3=A0 08:15, Sharat Masetty a =C3=A9crit :
>=20
> > Unfortunately toggling this config setting CONFIG_IPV6_ROUTER_PREF =
did
> > not help, I see the same problem in both cases.
> > The kernel version I am using is 3.10.0.
> >=20
> > Thanks for confirming that this is a non issue on 3.13 kernel versi=
on.
> > Would you happen to know which patch would have potentially fixed t=
his
> > issue?
>=20
> Your problem looks like the following one :=20
> http://marc.info/?l=3Dlinux-netdev&m=3D137280268407054&w=3D2
>=20
> Which has been fixed in 3.10.4, and 3.11+

Yes, that could very well be the case. We resolve the gateway while
inserting the route (if not on-link), and it may not be available
because of missing probes or no traffic went to it, yet. Thanks for
looking after this, Emmanuel.

I really recommend using the stable kernels btw. instead of the vaniall=
a
point zero releases.

Thanks,

  Hannes

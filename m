From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Tue, 17 Mar 2009 08:50:12 +0100
Message-ID: <1237276212.18086.11.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain>
	 <b6a2187b0903161655q15437156qc926c8db37d8ba4b@mail.gmail.com>
	 (sfid-20090317_005551_652269_7D5AC813)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-lkT8FdbDuHdh8xzkiIpe"
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0903161655q15437156qc926c8db37d8ba4b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20090317_005551_652269_7D5AC813)
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-lkT8FdbDuHdh8xzkiIpe
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-03-17 at 07:55 +0800, Jeff Chua wrote:

> > IOW, if you've pinpointed 71c11fb57b924c160297ccd9e1761db598d00ac2 as
> > being bad, then you should go back and double-check that its parent
> > (in this case 4607816f608b42a5379aca97ceed08378804c99f) is good.
> > Because if it's parent is also bad, then that just means that you made
> > some mistake in "git bisect".
> > In this case, it really sounds like maybe you marked the parent good, e=
ven
> > though you should have marked it bad.
>=20
> I should have been more careful, just got thrown off during the last
> few steps of the bisect. But with the bad association to the AP after
> a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9 (iwlwifi: remove implicit
> direct scan), can someone suggest where to go from here?

That actually makes some sense, though I'm convinced the code I removed
there is actually wrong that doesn't mean it couldn't have had positive
side effects too. I'll take a look at it, in the meantime your time
would be better spent trying to capture what's going on on the air
instead of bisecting again.

If you don't have a second device to monitor, you can also create a
monitor interface as such:
	iw dev wlan0 interface add moni0 type monitor flags none

and run tcpdump on the resulting 'moni0' interface while you try to
associate etc. Write the packets to files and send them to me.

Due to this implicit scan modification in the driver that I removed,
however, I won't see scans in that file, so it won't be all that useful,
a capture made on a second device would be much better.

johannes

--=-lkT8FdbDuHdh8xzkiIpe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJv1YyAAoJEKVg1VMiehFYxv4P/3qk3ba1W7WeZDxeSWe5lzXw
7d4LuKDgw8TEpfZBZgcf4eZuZsmuXBZGa29LPEheLHMbICrGIxLbOlPFJ0xzv49+
FThedraa26mmAGU1Y1m/9Kpo8SKFNmfsVxi5rgjWUixA8HPk+038tABwQDdKkbS6
/cx1F3Au5RKsSXMMIebI6/7EF9z8Znv3TD7ymVdp5q5kXPgDRVJJisDg6eXaoVHg
gJaJrkFnwXKVV/oAdAPbmjNpbtOrxA68VTxxtmAkGs+LuW9B1p4R9YFb3cnfBiCj
IXwOLPG6DzMqU/txXIWo0Z79Y0F4LKysIX5+NtnAKh2KXv9QntAHtcCAYju8uc0S
KZTbwSkWGWnfFRtdIoe0dbZ831OPSToCeEz1a1AdLkI2wksrvc0U12ZyfJ7orRnz
JvcorvGT/zKclXMegdL0aX9UAq+K47WjeX/oJ4wvbRuEkdai+lJ66VYDzzu1RsTj
wBWeJLcn14adDWa0mWqfOdmgkJ4CtmnpMPq30GN47E8lV2/mhRXOOHjnQbwaQPmc
1Q9GhSjRLQI08gmJctO+qAizmt4CDgxYTHxiN2DQMRriHVlzJ2fGsKp58kXYWa4k
Nh0BphA2dKPci7ZLcumBN9oP9X3FCE5SYXiI/sDkQ1Klz6tngXj7JeobjfqxW61P
YAE5sRPTNvhTqV6e+Cfi
=iPZ1
-----END PGP SIGNATURE-----

--=-lkT8FdbDuHdh8xzkiIpe--

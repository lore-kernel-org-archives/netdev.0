From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 14:43:30 -0600
Message-ID: <200501131443.34174.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501131328.34449.jeremy.guthrie@berbee.com> <20050113120050.0c734df5.davem@davemloft.net>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart10540886.MM5IrbZhTB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050113120050.0c734df5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart10540886.MM5IrbZhTB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I don't show that proc file being there.  I see it in 'iproute.c' but not i=
n=20
proc.

On Thursday 13 January 2005 02:00 pm, David S. Miller wrote:
> On Thu, 13 Jan 2005 13:28:29 -0600
>
> "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:
> > You can see below I am over 600K entries before it blows them away and
> > restarts.  How do I bump up the time from 10 minutes to something longe=
r?
> > With the way our system works, entries should be good for a day as we
> > won't reprogram the policy route table but once a day.
>
> Increase /proc/sys/net/ipv4/ip_rt_secret_interval

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart10540886.MM5IrbZhTB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5t12qtjaBHGZBeURAqKCAJ0VKnhvq9Na4+cdNHUfL/Js7i5qwQCdHcAx
o+vhNCrS3lz+OO0+ZvK7IgA=
=3cFq
-----END PGP SIGNATURE-----

--nextPart10540886.MM5IrbZhTB--

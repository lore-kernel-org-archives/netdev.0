From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 17:23:18 -0600
Message-ID: <200501121723.21969.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121647.30934.jeremy.guthrie@berbee.com> <16869.45158.194375.398326@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1388314.TvAxB0A7hL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.45158.194375.398326@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1388314.TvAxB0A7hL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 12 January 2005 05:19 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > Here is what it looked like I was getting before from the old driver...
>  > that took me down to 8mbps.
>  >
>  > "printk: 4624 messages suppressed.
>  > dst cache overflow
>  > printk: 4630 messages suppressed.
>  > dst cache overflow
>  > printk: 4631 messages suppressed.
>  > dst cache overflow
>  > printk: 4646 messages suppressed.
>  > dst cache overflow
>  > printk: 4645 messages suppressed.
>  > dst cache overflow"
>
>  Thanks!
>
>  This a known problem. Remember I asked you about this. We're now in the
>  RCU route-hash problem again. This is not necessary solved by more CPU
>  as higher t-put forces more dst-entries to be freed aand we get
>  closer to max_size.
>
>  As your traffic looks sane double your bucket size of the route hash to
>  start with. Use the boot option w. rhash_entries. look at rtstat
Does it make sense that the driver would kill throughput and force us to=20
output these types of messages?

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1388314.TvAxB0A7hL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5bFpqtjaBHGZBeURAlTAAJ0Rr8D4lKpObZ+keb8zLq5d5v0FKACgnKXD
/3Lh4StZBXdA6uCqhjlTO4Y=
=UdhW
-----END PGP SIGNATURE-----

--nextPart1388314.TvAxB0A7hL--

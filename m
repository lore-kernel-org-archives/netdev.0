From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 20 Jan 2005 11:14:46 -0600
Message-ID: <200501201114.49517.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501200837.40734.jeremy.guthrie@berbee.com> <16879.58333.266843.335475@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1881411.M4NkWWNZBR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16879.58333.266843.335475@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1881411.M4NkWWNZBR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 20 January 2005 11:01 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  > 1024 buffers on the RX of eth3.
>  > >  >
>  > >  > echo 86400 > /proc/sys/net/ipv4/route/secret_interval
>  > >  > echo 524288 > /proc/sys/net/ipv4/route/gc_thresh
>  > >
>  > >  rhash_entries?
>  >
>  > I left that at 2.4 million.
>  >
>  > >  > It appears to be cruising right along now.
>  >
>  >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     to=
t=20
>  >    mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
>  > 524291     74169     779     0     0     0     0     0         2      =
 0
>  > 1610369017     516       0         0    0           43612          0
>  > 524287     74830     777     0     0     0     0     0         6      =
 0
>  > 0     498       0         0    0           40504          1
>  > 524285     77458     949     0     0     0     0     0         4      =
 0
>  > 0     619       0         0    0           42731          1
>
>  Linear search is under control and number of dst entries very high but
> very constant at the cost of calling GC a number of times second. But I
> don't understand why we do not see any GC ignored.=20
When does GC normally ignore?

> Did you ever write to=20
> gc_min_interval in proc?=20
I left /proc/sys/net/ipv4/route/gc_min_interval at zero.

> Never seen rtstat's like this but it seems to do the job.

More numbers from right now with higher PPS rate.
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc=20
GC: tot ignored goal_miss ovrf HASH: in_search out_search
524291     92192     848     0     0     0     0     0        17       0=20
537114631     553       0         0    0           50947         18
524287     95496     846     0     0     0     0     0         4       0=20
1610369017     539       0         0    0           52000          4
524293     98503     791     0     0     0     0     0         7       0   =
  =20
0     525       0         0    0           53119          3
524290     98711     965     0     0     0     0     0         3       0   =
  =20
0     626       0         0    0           53448          3


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1881411.M4NkWWNZBR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB7+cJqtjaBHGZBeURAjwaAJ4iC+M1ceW6Bxdt1QfihLuBdyukwwCdEOfV
AcWUUMGTUkx4XUp9PtlI2Q8=
=L3uC
-----END PGP SIGNATURE-----

--nextPart1881411.M4NkWWNZBR--

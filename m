From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 20 Jan 2005 08:37:36 -0600
Message-ID: <200501200837.40734.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501191950.08567.jeremy.guthrie@berbee.com> <16879.38457.4576.598144@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2546304.NdYkW6LUQn";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16879.38457.4576.598144@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2546304.NdYkW6LUQn
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 20 January 2005 05:30 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > @ 14:51:44 we can see the secret_interval kick in.  Otherwise we run
>  > very solid.
>  >
>  > 101Kpps  8)
>
>  Seems traffic increaed a little bit too?
>
>  > 1024 buffers on the RX of eth3.
>  >
>  > echo 86400 > /proc/sys/net/ipv4/route/secret_interval
>  > echo 524288 > /proc/sys/net/ipv4/route/gc_thresh
>
>  rhash_entries?
I left that at 2.4 million.

>  > It appears to be cruising right along now.
>
>  Nice. rtstat's is still interesting so we can see number fib lookups and
>  linear search and GC dynamics etc.
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc=20
GC: tot ignored goal_miss ovrf HASH: in_search out_search
524291     73651     805     0     0     0     0     0         5       0=20
537114631     537       0         0    0           45657          3
524291     74169     779     0     0     0     0     0         2       0=20
1610369017     516       0         0    0           43612          0
524287     74830     777     0     0     0     0     0         6       0   =
  =20
0     498       0         0    0           40504          1
524285     77458     949     0     0     0     0     0         4       0   =
  =20
0     619       0         0    0           42731          1
524273     75475     801     0     0     0     0     0        10       0   =
  =20
0     549       0         0    0           40084          7
524292     76740     902     0     0     0     0     0         5       0   =
  =20
0     574       0         0    0           41702          3
524295     76681     829     0     0     0     0     0         4       0   =
  =20
0     527       0         0    0           42328          2
524333     76522     756     0     0     0     0     0         9       1   =
  =20
0     432       0         0    0           43621          3
524286     80323     792     0     0     0     0     0         6       0   =
  =20
0     498       0         0    0           44619          2
524294     79409     758     0     0     0     0     0         6       0   =
  =20
0     508       0         0    0           45864          3
524288     80058     756     0     0     0     0     0         7       0   =
  =20
0     478       0         0    0           44711          5
524291     77128     794     0     0     0     0     0         8       0   =
  =20
0     516       0         0    0           42301          3
524288     77433     823     0     0     0     0     0         4       0   =
  =20
0     539       0         0    0           42357          0
524293     79423     761     0     0     0     0     0         7       0   =
  =20
0     514       0         0    0           43102          3
524293     80940     804     0     0     0     0     0         6       0   =
  =20
0     530       0         0    0           45457          3
524287     84864     813     0     0     0     0     0         3       0   =
  =20
0     532       0         0    0           44309          0
524286     78358     804     0     0     0     0     0         6       0   =
  =20
0     531       0         0    0           43669          2
524293     72760     717     0     0     0     0     0         2       0   =
  =20
0     480       0         0    0           41611          0
524287     72833     684     0     0     0     0     0         5       0   =
  =20
0     464       0         0    0           40571          1
524290     77308     726     0     0     0     0     0         6       0   =
  =20
0     486       0         0    0           43031          2
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc=20
GC: tot ignored goal_miss ovrf HASH: in_search out_search
524288     81205     746     0     0     0     0     0         5       0=20
537114631     512       0         0    0           42384          3
524291     81744     736     0     0     0     0     0         5       0=20
1610369017     494       0         0    0           43980          3
524285     85813     766     0     0     0     0     0         5       0   =
  =20
0     485       0         0    0           45385          3
524290     80609     810     0     0     0     0     0         5       0   =
  =20
0     547       0         0    0           42037          2
524281     75730     784     0     0     0     0     0         7       0   =
  =20
0     515       0         0    0           42966          3
524295     78139     805     0     0     0     0     0         6       0   =
  =20
0     540       0         0    0           43026          3
524292     77198     724     0     0     0     0     0         7       1   =
  =20
0     484       0         0    0           44583          1
524301     80243     802     0     0     0     0     0         7       0   =
  =20
0     524       0         0    0           43462          2
524286     78010     822     0     0     0     0     0         8       0   =
  =20
0     557       0         0    0           44684          4
524292     76739     814     0     0     0     0     0        11       1   =
  =20
0     539       0         0    0           45128          5
524288     79226     765     0     0     0     0     0         6       0   =
  =20
0     518       0         0    0           47706          1
524286     78367     757     0     0     0     0     0         8       1   =
  =20
0     486       0         0    0           44462          1
524292     79453     774     0     0     0     0     0        10       0   =
  =20
0     514       0         0    0           43612          5
524291     75541     749     0     0     0     0     0        10       0   =
  =20
0     492       0         0    0           43462          3
524289     77849     748     0     0     0     0     0        14       3   =
  =20
0     493       0         0    0           43390          7
524296     77628     773     0     0     0     0     0         8       0   =
  =20
0     505       0         0    0           43900          3
524295     79695     699     0     0     0     0     0         8       0   =
  =20
0     451       0         0    0           45529          4
524293     78484     770     0     0     0     0     0         7       0   =
  =20
0     339       0         0    0           44700          2
524298     79257     732     0     0     0     0     0         8       0   =
  =20
0     486       0         0    0           45880          4
524287     79434     749     0     0     0     0     0        12       0   =
  =20
0     496       0         0    0           45081          5

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2546304.NdYkW6LUQn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB78I0qtjaBHGZBeURAsTKAJ0Zm9UNi8F662SsdGsRWvEMFMKQkgCgiYI9
epww+bzL/MCI5VTGRztx5Sw=
=LjGK
-----END PGP SIGNATURE-----

--nextPart2546304.NdYkW6LUQn--

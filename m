From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 10:17:26 -0600
Message-ID: <200501071017.31751.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061618.24465.jeremy.guthrie@berbee.com> <16861.48463.770166.352726@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1340695.bQ2qdNF43y";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.48463.770166.352726@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1340695.bQ2qdNF43y
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 January 2005 04:35 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > You mentioned before that " The stats didn't show any numbers so we
>  > don't know your load."  Was there a command you wanted me to re-run?
>
>  rtstat should show the routing/packet load.
>
>  From a systems like yours 2*933 MHz PIII in production for tens of
> thoundans of users many filter and full BGP routing. Current (late here)
> use.
>
>
>  ifstat2 eth*
>              RX --------------------------   TX -------------------------
> eth0          272.8 M bit/s       51 k pps    350.7 M bit/s       51 k pps
> eth1          371.9 M bit/s       55 k pps    293.6 M bit/s       55 k pps
> eth2            6.7 M bit/s     1348   pps      3.0 M bit/s      991   pps
> eth3            472   bit/s        0   pps      600   bit/s        0   pps
Ifstat output:
#kernel
Interface        RX Pkts/Rate    TX Pkts/Rate    RX Data/Rate    TX Data/Ra=
te
                 RX Errs/Drop    TX Errs/Drop    RX Over/Rate    TX Coll/Ra=
te
lo                     0 0             0 0             0 0             0 0
                       0 0             0 0             0 0             0 0
eth0                   1 0             1 0            66 0           178 0
                       0 0             0 0             0 0             0 0
eth2                   0 0         30770 0             0 0        13361K 0
                       0 0             0 0             0 0             0 0
eth3               81019 0             0 0        41740K 0             0 0
                       0 0             0 0             0 0             0 0

> rtstat
>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot  =
 =20
> mc GC: tot ignored goal_miss ovrf HASH: in_search out_search 21007  =20
> 114060     748     0     5     0     0     0        11       5      0    =
 =20
> 0       0         0    0           58280          4 22683    112556     8=
27
>     0     6     0     0     0         5       5      0       0       0   =
 =20
>    0    0           60841          7 24230    111083     765     0     4 =
 =20
>  0     0     0        13       4      0       0       0         0    0   =
 =20
>      66628          7
> Around 110 kpps hitting warm cache entries and ~800 new lookups/sec. I was
> expecting so see something similar from your system.
Did my second email w/ the lnstat data not make it?

>
> FYI.
>  cat /proc/net/softnet_stat


total    droppped tsquz    Throttl  FR_hit   FR_succe FR_defer FR_def_o=20
 cpu_coll=20
> 9ba490f3 00000000 01281572 00000000 00000000 00000000 00000000 00000000
> 002562c2 9939268d 00000000 010e42e9 00000000 00000000 00000000 00000000=20
> 00000000 0028fe72
Why do these drops not show up in the interface drop?

> Good Night.
>
>
>           --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1340695.bQ2qdNF43y
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3rYbqtjaBHGZBeURApowAJ9tp9NRJazOm/HsVeC4ANYiDgyzjgCghJBx
U1Pf8s66CXj3d7Zk3O7yBzQ=
=AMaR
-----END PGP SIGNATURE-----

--nextPart1340695.bQ2qdNF43y--

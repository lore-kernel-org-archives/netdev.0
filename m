From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 14:52:57 -0600
Message-ID: <200501051453.03022.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501051325.40616.jeremy.guthrie@berbee.com> <16860.19615.251360.169722@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2053757.ArktrbUOaq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16860.19615.251360.169722@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2053757.ArktrbUOaq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 05 January 2005 02:22 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > After smp_affinity adjustments and turning off IRQ balancing.
>  >
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >
>  >           RX packets:537271635 errors:2377048 dropped:2377048
>  > overruns:1849169
>
>  Worse?
>
>  Yes. I'll remember Hararld moved rt_cache_stat /proc/net/stats/ and wrote
> a new utility for it. Should be in iproute2 package.  Stephen knows the
> details. Otherwise change path in rtstat. You need this to relate and
> verify the load.
Hm...
ls -la /proc/net/stat/
total 0
dr-xr-xr-x  2 root root 0 Jan  5 14:47 .
dr-xr-xr-x  5 root root 0 Jan  5 11:50 ..
=2Dr--r--r--  1 root root 0 Jan  5 14:47 arp_cache
=2Dr--r--r--  1 root root 0 Jan  5 14:47 clip_arp_cache
=2Dr--r--r--  1 root root 0 Jan  5 14:47 ndisc_cache
=2Dr--r--r--  1 root root 0 Jan  5 14:47 rt_cache


>  Check throughtput and how packet load is used with 2.4.
> /proc/net/softnet_stat and rtstat.=20
Will do.

> Also meditate how the comparison can be=20
> fair wrt taffic patterns. Do smame with 2.6.
Not sure I follow.  I can see higher pps/byte through puts on switch port=20
counters when I run with 2.4 vs 2.6.  I'll double check though.  I am the=20
'dev' state so I can swap between V2.4 and V2.6 as necessary to compare=20
during roughly equivalent times.  The only delay is the time between reboot=
s.

>  Prepare for a oprofile. I'm lazy and compile the stuff I use into kernel
> if you can get the same result w. nodules it's ok.
Okay.

>
>
>         --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2053757.ArktrbUOaq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3FOuqtjaBHGZBeURArx5AJoD1hHvaB93tJpQtWF6wrOGpNfBugCfTtEj
L/NGCQWMNHjI4Au8pD6LJNc=
=4LXK
-----END PGP SIGNATURE-----

--nextPart2053757.ArktrbUOaq--

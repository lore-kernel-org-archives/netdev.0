From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 16:21:20 -0600
Message-ID: <200501121621.24259.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121445.51780.jeremy.guthrie@berbee.com> <16869.40556.711969.512311@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2100738.tuNY47F5dT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.40556.711969.512311@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2100738.tuNY47F5dT
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 12 January 2005 04:02 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > My throughput dropped from 500 mbps to 8mbps.  8(
>
>  Weird!
>
>  >            CPU0       CPU1
>  >  18: 3586173518       1815   IO-APIC-level  eth3
>  >  20:          2 2464382507   IO-APIC-level  eth2
>  >
>  >            CPU0       CPU1
>  >  18: 3586173518       1815   IO-APIC-level  eth3
>  >  20:          2 2464387985   IO-APIC-level  eth2
>
>  There are no irq's on eth3 at all so RX softirq is constantly running.
>  Which means it's deferred to ksoftirqd now and running under scheduler
>  context. Do you have anything that competes with ksoftirqd for CPU0 on
>  your system?
This box is primarily routing.  Nothing should be competing for CPU0

>  It used be recommended to increase the priority of ksoftirqd but I wonder
>  what's going on your system. We see interrupts on eth2...
>
>  And tsquz (3:rd col) in /proc/net/sofnet_stat indicates there are very
>  little activity from the RX softirq. It's soon time time up here.
>
>
>       --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2100738.tuNY47F5dT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5aLkqtjaBHGZBeURAqPUAKCY4On9c9TeGVvpWsAhsTl2H5LyMACeKHrh
LhFPTb7EqMTqNcD/NhLpwog=
=93SE
-----END PGP SIGNATURE-----

--nextPart2100738.tuNY47F5dT--

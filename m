From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 16:18:21 -0600
Message-ID: <200501061618.24465.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061546.32116.jeremy.guthrie@berbee.com> <16861.46969.536236.11355@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1568023.hnZFYY8YNB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.46969.536236.11355@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1568023.hnZFYY8YNB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 January 2005 04:11 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  I don't follow...
>  >
>  > Technically by turning off NAPI, I have 'solved' my short term packet
>  > loss problem.
>
>  You need NAPI of course just wait until your packet load increases just
>  a little bit...=20
I agree.  Running mpstat now shows that even w/o packet drops, I'm running=
=20
2-5% free CPU.

>  I saw drops in your 2.4 /proc/net/softnet_stat which=20
>  indicates you are close to your system performance.=20
Should those drops show up in RX drops in ifconfig?

>  With NAPI you keep=20
>  up your system system performance regardless of incoming load.
You mentioned before that " The stats didn't show any numbers so we don't k=
now=20
your load."  Was there a command you wanted me to re-run?

>  The e1000 driver has some bugs in "your setup" as it enables irq's when
>  there is only RX and no TX and should have irq's disabled. I sent patch
>  to intel.
>
>            --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1568023.hnZFYY8YNB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3bkwqtjaBHGZBeURAhwtAJ0dxJdldtO4/T6CJ8GUHnZeyCD8MwCdE0qt
FNGzOiQeLVhCPgFf47mSIvM=
=JJXF
-----END PGP SIGNATURE-----

--nextPart1568023.hnZFYY8YNB--

From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 16:30:50 -0600
Message-ID: <200501121630.53099.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121605.12943.jeremy.guthrie@berbee.com> <16869.41793.881555.323604@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1945889.UB1T3PPquv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.41793.881555.323604@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1945889.UB1T3PPquv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 12 January 2005 04:22 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > I am now getting some push back from the project manager on this
>  > performance problem.  I am wondering if you think faster CPUs will
>  > a)  help relieve the symptoms of this problem
>  > b)  not help because now we will hit a '# of routes in the route-cache'
>  > problem
>  > c)  or will help to a point till the # interrupts come back and bite u=
s.
>
>  Back out the patch I sent.and have hardirq's to run RX-softirq as you
>  did before but something is very wrong. You didn't answer if there were
>  other load on the machine...
I have backed out.  As for the load, this box only does policy routing.  An=
y=20
other functions it performs are part of its automated system to download th=
e=20
next days policy-routing config.

>  route-cache can probably be tuned you as have four times the linear seach
>  I see in one PIII system at 110 kpps w. production traffic.
How would I go about tuning that?

>  Of course the non-engineering solution is to buy more CPU... :-)
That is good to know.  This will help me calm the situation a bit.  8)

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1945889.UB1T3PPquv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5aUdqtjaBHGZBeURApEcAKCI5TZdl+4KHLboUT3Tw80TOjOkOQCggtPo
+x1DUJ++tTezj8QtfRP/aIs=
=X9P7
-----END PGP SIGNATURE-----

--nextPart1945889.UB1T3PPquv--

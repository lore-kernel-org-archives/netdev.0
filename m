From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: sun4i_handle_irq: WARNING at net/ipv4/tcp_input.c:2711
 tcp_fastretrans_alert
Date: Thu, 17 Oct 2013 14:32:03 +0200
Message-ID: <20131017123203.GM3041@lukather>
References: <20130821094432.GA28249@lnx-rg>
 <20130823182116.GE1230@lukather>
 <CACQ1gAinSoTCTtf9Y6TL=vtEm1jnJgis0n=y=frNtuPxue9-ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z7bbLlDR+qKEHzO8"
Cc: Stefan Roese <sr@denx.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Genoud <richard.genoud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACQ1gAinSoTCTtf9Y6TL=vtEm1jnJgis0n=y=frNtuPxue9-ng@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--z7bbLlDR+qKEHzO8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Richard

On Thu, Oct 17, 2013 at 01:46:49PM +0200, Richard Genoud wrote:
> > Hmmm, that seems pretty far from the network/interrupt drivers, and it
> > looks like other users have seen this on !ARM machines:
> > http://forums.gentoo.org/viewtopic-p-7379928.html
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D989251
> >
> > There's a patch in the redhat's bugzilla, could you try to apply it and
> > see if it solves your problem?
> >
> > Maybe the netdev guys will have other ideas as well.
> For the record, I set:
> net.ipv4.tcp_early_retrans =3D 2
> net.ipv4.tcp_frto =3D 0
> And I didn't see the warning any more.
> It's seems that a patch is on it's way. I'll try it instead of setting
> the sysctl.
> http://thread.gmane.org/gmane.linux.network/286793

Ah, I wanted to ask you about the status of this.

Thanks for the follow-up,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--z7bbLlDR+qKEHzO8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSX9jCAAoJEBx+YmzsjxAgEkMQALfSDDLIIZazDHaeKV+TqxqW
+xvXAyJiolm7rRYCncBzzRDG4AKGbTTQXpXltw+cSoW4BVaRJ2vAdHl8atS/7m1M
e+HegI+l+DUGSwcld/kvocUoWlI089dYF2AlG0qZxQnbmIyX79RVWiADxmKKkx33
U2SN13WSjt27VnNa+RzC/xyV6l7vqfJyMoWbwSQwa00A4s4AflcPVTRUPLXZKfUs
vsrPJTqIHag+3KSBtuqDg/ulPxuZ3nHHLRX47wiDADqhmNi6c/2GxtJoU0f1CBfF
P1Zn1oxa9wzHuYI09XhDORpRZQ02OGlQHJEcxQinOzT8fDD16YS6aeyTEe89//03
t6ZGuwPvrlmO4mjaMhlE2SfnYdlPrmC0lp0DoLmSvVag6CoV+WfXh5SAA8+locAR
cOktyQaov5KjZBDhNvCPg1ekNheKJVoL5YQbhWmC3PYcYloCF1uxOJoNRQ/NufBG
0HXjxFtCrR4ZyP2Mm6xWHuQdQ9Vy4ruS1Q/ReT5+PKqKFLwd6fr0+3RzDia2+6P6
5Ljhk1SJgAeNXOj50UA5+jpeqBoyz0xhhvHJoHK8k/m0kuuR7msT1TIGzTILiJnz
oV8qRsU20iJ3bz+yshGlE72eSEPydyLOR9POh9k6UFmAqjOx8TIwks8NKwHT3ZHC
5oXiVRxhzq5AY5TC4M9D
=n0z3
-----END PGP SIGNATURE-----

--z7bbLlDR+qKEHzO8--

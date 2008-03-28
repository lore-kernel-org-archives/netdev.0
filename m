From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 23:14:59 +0100
Message-ID: <1206742499.22530.90.camel@johannes.berg>
References: <47ED3F1A.1090101@linux.intel.com>
	 <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
	 <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org>
	 (sfid-20080328_205203_254278_BF9EB41F) <1206738071.22530.80.camel@johannes.berg>
	 <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org>
	 <1206740581.22530.83.camel@johannes.berg>
	 <alpine.LFD.1.00.0803281500100.14670@woody.linux-foundation.org>
	 (sfid-20080328_220218_778405_97FC8D85)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aXF4e4I+WnOwyR7EhsWr"
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Dmitry Torokhov <dtor@mail.ru>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46093 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbYC1WPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 18:15:10 -0400
In-Reply-To: <alpine.LFD.1.00.0803281500100.14670@woody.linux-foundation.org> (sfid-20080328_220218_778405_97FC8D85)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aXF4e4I+WnOwyR7EhsWr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Ahh. So it's easily repeatable for you.. Do you think you could bisect it=
?=20
> At least a few runs? Even a partial bisection will give a nice (=3D=3D mu=
ch=20
> smaller) range of commits to be blamed, and might tell us why it started=20
> happening..

Unfortunately, it takes forever on this machine to compile a kernel
after any bigger changes. I can do it early next week when I have access
to my bigger box again.

On the other hand, it should be easily reproducible by anyone else with
the same trick, here's what I do:

 * configure X to use /dev/input/event* devices
 * in an xterm, do something like
      rmmod usbhid ; modprobe usbhid
 * switch to a VT
 * watch kernel crash as X releases the grab on the event device

Mind you, I actually did this with the appletouch driver, but I don't
think it makes a difference since the problematic thing is the code that
X grabs the device. A trivial program that executes the grab ioctl would
probably suffice if you leave it running over a rmmod/modprobe cycle.

johannes

--=-aXF4e4I+WnOwyR7EhsWr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+1t4qVg1VMiehFYAQIyVA//YCg2FLSChFspD/yc2Qw/7VHT0+4x34Hx
Y/ZjriGYJzH94H3eZfS/Vsi8I5fsthSFp7KQeuwaA3dO3dQt1vJipjuB6frPAf8/
uE2MvnleDv0nLcq9wXY7pYGVT4GZzvym0gmdoASoVnNvdEtlRpZpOo45uXAJfD1q
++1AIdGoRwEBUHphGl+Q4lwRl6bcwZhxbeBl2cgpAyjDbqHav9tQAP21z9AxNcYl
gADGE2yAou0/a/tXinv63MM0f/HkwCl6Vdo/vRYWTgWvLPTBFQSFfFZPTZ7Dxwq4
5vYhJb0wXndQQLMz/B5BU/fn0Pb2y40/uhpheL62Hbppu/jLM3G2uBFlcxd1Vure
a4nn8I04/5Dsk4CdpnkB5+ntx+8d2Jat661EYxBiQ+lXJdVoENlUKTyVJykcFyxG
8ba3GfaASTeZ2S02T6lE1TBGaKlGEp9ujb47v1o05hYunKaONFrDV4Lt1Zmyf++7
nYjm/asWdYb4wep/sKBKb708js+lbL707Y8xa2v7YAiuCvz76pqiCH6nnaJrAtqg
B2lqPnKnt0DDTl1y+9cWEEIR2Z4k7rLNd3NczGoZ/q5hfe2QrX19Wk4t0EgK4gy9
Hk4JCJmMYQxdB0djoDu4iP4mPvqJVAzqaLjPuOrQ1qa6inIVFtsl+B91HBD1J7/3
XvTrGye1mV4=
=bQFa
-----END PGP SIGNATURE-----

--=-aXF4e4I+WnOwyR7EhsWr--


From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Wed, 13 Dec 2006 18:37:37 -0500
Message-ID: <200612131837.41663.flamingice@sourmilk.net>
References: <200612110044.12205.flamingice@sourmilk.net> <200612121826.38479.flamingice@sourmilk.net> <20061213225452.GC20700@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6706508.9PeZhy7sI9";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:34323 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751800AbWLMXiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 18:38:06 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061213225452.GC20700@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6706508.9PeZhy7sI9
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 13 December 2006 17:54, Ulrich Kunitz wrote:
> I mean on the other hands we break APIs for four or=20
> eight bytes and here we spend a whole device strucuture and sysfs
> directory for something the wlan device firmware represents with a
> single bit. To call the housekeeping functions overkill under
> these circumstances appears not to be very rational.
>
I do not consider the housekeeping functions overkill, but the function tha=
t=20
it performs (eg. not confusing the user by keeping the LED off) can be done=
=20
with less brute force.

> It should also be mentioned that the LEDs on the ZD1211 devices
> are not independent devices, because they are partly controlled
> by the firmware. That's exactly where some of the issues with your
> patch are.
>
The link light can be treated as an independent device as long as the other=
=20
LED bit is not flipped. As I mentioned before, fixing that isn't a problem.

> Let the device drivers do the blinking, but give them a chance to
> know about status changes at the MAC layer, without mandating to
> implement a LED device.=20
I guess you don't like the LED trigger code currently in d80211 then and wo=
uld=20
rather see it removed. As far as I can tell, this patch is just a symptom o=
f=20
that issue.

=2DMichael Wu

--nextPart6706508.9PeZhy7sI9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFgI7FT3Oqt9AH4aERAhMgAKCjOaDvCwxT16Z5H/c6vLxRRpN6EQCfeSRy
p7H7dIVLBCTO6cD1hXwI838=
=RPHt
-----END PGP SIGNATURE-----

--nextPart6706508.9PeZhy7sI9--

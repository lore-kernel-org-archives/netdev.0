From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: 3945 driver using d80211
Date: Tue, 8 Aug 2006 14:40:43 -0700
Message-ID: <200608081440.48623.flamingice@sourmilk.net>
References: <44D901C9.6090304@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1799954.gXElGGFlfq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:39595 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S965055AbWHHVky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 17:40:54 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44D901C9.6090304@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1799954.gXElGGFlfq
Content-Type: text/plain;
  charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 08 August 2006 14:27, Mohamed Abbas wrote:
> 2- Scanning; in 3945 driver, we can not tune to other channels while we
> are connected, this will cause a firmware error. The firmware provides a
> scanning command we call so the firmware will take care of switching of
> the available channels and gather beacons and probe responses. The
> current d80211 the stack will call config callback to switch to
> different channel and send the probe requests. One of our engineers did
> come up with a patch to add one more callback function if provided the
> d80211 will call this function to allow the registered driver to perform
> the scanning functionalities. For work around I currently check inside
> config callback if the scanning flag set I will issues the scan command
> then ignore the next config callback.
>
I think it would be best if you made the firmware not be aware of a=20
connection, and let the d80211 code take care of all the=20
scanning/authenticating/associating. Of course, I know nothing about 3945, =
so=20
I don't know if that's possible.

=2DMichael Wu

--nextPart1799954.gXElGGFlfq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE2QTgT3Oqt9AH4aERAogwAKC7SKv3GAW45ZWejqVzvJm+klL2agCeJrwf
Z8diruaBZDXlT3VGYEy7p14=
=plYt
-----END PGP SIGNATURE-----

--nextPart1799954.gXElGGFlfq--

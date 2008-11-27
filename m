From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 27 Nov 2008 12:23:52 +0100
Message-ID: <1227785032.3809.84.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <1227783281.3809.78.camel@johannes.berg>
	 <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kY7KGiSZlhpQsLqxR1LL"
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57826 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966AbYK0LYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:24:43 -0500
In-Reply-To: <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kY7KGiSZlhpQsLqxR1LL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> The idea is to make the WiMAX subsystem more generic and create =20
> something similar to what we have with mac80211/cfg80211 and also =20
> inside Bluetooth. This is the common starting point and next step is =20
> to move functionality that has been identified as generic and common =20
> from the driver into the subsystem.

The problem is with the current stack design this isn't really possible,
since the stack only provides like three real commands:
 * talk to driver
 * reset device
 * do rfkill (though I'm not sure why this is needed)

> I prefer if we do this development inside the kernel tree instead of =20
> externally. One big thing we should have learned from mac80211 is that =20
> developing a full stack outside the kernel source tree is not really =20
> working out. We should apply the same model as we did for ext4 or what =20
> Greg is doing with his staging tree.

The problem with that is that the stack is setting APIs in stone that
are, if you ask me, suboptimal. Once we add those, I don't see how we
can migrate away from a "command handled by driver" model towards a
"command handled by stack and appropriate driver callback called" model,
which would be more like cfg80211/nl80211 rather than iwpriv.

> It has been open source since quite some time now at linuxwimax.org =20
> (exception are some tiny binary pieces).

Ok, sorry, I thought there was a bunch of binary code still.

johannes

--=-kY7KGiSZlhpQsLqxR1LL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLoNFAAoJEKVg1VMiehFY1sgP/0yjIBaEz+7LsWLplYuKjGsU
PnFFsyNi4B5LhvXioM17Mhw5ELQw4MvmMtkKN1bVUpLt3vU8YnvEoOJl2N6JmRUL
Fml+II1RWzedubKgpLtH3Q63rgw2igTb5TGe4qngXpglHZWZpwOVltnzyk+WP7kf
raxz+NssW7r7DyAN/wpDycr2KCH2slbWGmCKgs+QIwIaotKjnCeqN4OEqKCaIafC
XzwWsMHSycI1+xptPfM8aIqArruTgsODqKNSPaAUdqGBaiTwwD93w2dtx7XeKW+g
Qtp0C2lzwGPbffjbAS1AW7avOKt22Ffons+8IWz04HP8H7WGpRq4h2a9aLNq0jdr
Up03UsP3sPqhFdjfE9CCgFPp0WdjZJIMtE2NSqI2WRgwKc6LVKnnkgh6KF7btmfM
/U2wxBHABvk6WxF2hvoC/LLhz9W+Y8y4Wp5tWGtYZrt/Jb1boC9gYWI3l3E7sHy7
f3bp3cXvhRHo/CSCYM4zMfhF8Gv5G5QkBM2IKsAa9Y9pW7voJYA6tx/NvjlpNn/A
neTlzgdISIoqRjZPSMDPN3EODBcKhH+U1qjBkfEzgrC63oVU+oXl4OAJ6iCjN0mu
rDQjouRnAfDYHZ1gpXz3UnpPM5l7h99LDPjQ8Ijtilop3efc5t6RiXhp/4TAS+D5
GN7mW8w0AE/SnNcuVpbb
=tMyB
-----END PGP SIGNATURE-----

--=-kY7KGiSZlhpQsLqxR1LL--


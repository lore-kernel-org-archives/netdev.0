From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: [PATCH] udev: create empty regular files to represent net 	interfaces
Date: Fri, 30 Oct 2009 09:22:36 -0700
Message-ID: <4AEB12CC.1070300@kadzban.is-a-geek.net>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> 	<20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <4AEA997D.7070205@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig35748886999614F803ED49A2"
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	Matt Domsch <Matt_Domsch@dell.com>,
	dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <4AEA997D.7070205@suse.de>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig35748886999614F803ED49A2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hannes Reinecke wrote:
> And to throw in some bit of useless information;

Stirring the pot a bit myself with this message...

> The one reason I didn't to this was that a network interface is _not_
> a file, but rather an abstract type which is known only internally in
> the kernel (ie the one exemption from the 'everything is a file' UNIX
> rule).

Why?  Why not make it a file?  I've heard rumors of other Unix-like
systems that do exactly that, FWIW.

(Yes, I'm joking.  Well, maybe half-joking...  It'd be nice, but I don't
expect it to happen.)

> When I were to design this, I would be implementing network interface
> _aliases_, so that a network interface could be accessed either by=20
> name or by alias. This mechanism can then be managed by udev, much=20
> like we (ie SUSE) is using it nowadays to assign the network
> interface numbers.

The problem with that, if I understand what you're suggesting, is the
value of IFNAMSIZ, and the fact that it can't be made any bigger.  All
your aliases have to be IFNAMSIZ characters or less.  And that's too
short to be able to embed the same level of information as we get for
e.g. disks.  It's *barely* long enough to fit "mac-" plus 12 hex digits
(for the MAC address), but is completely incapable of holding a USB bus
path, for instance.

(Not that you'd want to use path persistence for USB devices.  But it is
possible that you'd want it for some other setup, at which point it
becomes impossible to use the same rules for USB.)


--------------enig35748886999614F803ED49A2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrrEtMACgkQYasYN+YI5W4xGgCfQxKh8tyJWRHp6k3XwlyxIMKU
vFIAnRLpQ3Q6nVsMP3tfIb2Zkh139vpg
=1eD4
-----END PGP SIGNATURE-----

--------------enig35748886999614F803ED49A2--

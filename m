From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Wed, 28 Feb 2007 10:16:05 +0100
Message-ID: <1172654165.3681.31.camel@johannes.berg>
References: <20070228012741.GA3988@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fqSkluyBxkpWE3nHXRW0"
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070228012741.GA3988-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-fqSkluyBxkpWE3nHXRW0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> 	Patch for 2.6.20 is attached.

... and in the meantime netdevices aren't class_device any more :) IOW,
your patch isn't going to work any more. Also, I think wireless could
benefit from this as well.

>         The kobject framework is well designed, so adding these
> features is trivial change and won't run the risk of breaking anything
> (famous last words). Obviously, hotplug apps are free to ignore those
> additional features.

Why not just add this to base kobject_rename instead? That way,
userspace is notified for all renames in sysfs.
The patch then collapses down to the change in net's sysfs code to add
the ifindex to the environment, and another change in kobject to invoke
a new event when a name changes and show the old name.

johannes

--=-fqSkluyBxkpWE3nHXRW0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF5UhV/ETPhpq3jKURApykAJ9ZUXi6bJwmnMglXvkrs/woCNvi/ACfduQ/
vK6NsgvxMQh5r4sZIJT1acU=
=U4iY
-----END PGP SIGNATURE-----

--=-fqSkluyBxkpWE3nHXRW0--

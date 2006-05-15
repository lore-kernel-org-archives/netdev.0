From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 15:59:47 +0200
Message-ID: <200605151559.50838.IvDoorn@gmail.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <20060515152513.5095b2d5@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1173420.JVXhNmTFHm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Mark Wallis" <mwallis@serialmonkey.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:46853 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964913AbWEON7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 09:59:04 -0400
Received: by nf-out-0910.google.com with SMTP id o63so108406nfa
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 06:57:54 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060515152513.5095b2d5@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1173420.JVXhNmTFHm
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 15 May 2006 15:25, Jiri Benc wrote:
> On Mon, 15 May 2006 22:57:12 +1000, Mark Wallis wrote:
> > Currently, in our rt2x00 (using the devicescape stack) we are firing of=
f an
> > ACPI event so that the hardware button can be handled in userspace. This
> > allows the user to basically do whatever they want when this button is
> > pressed - including bringing down the wireless interface. The problem h=
ere
> > is no distro's currently contain scripts to run from this event so for =
many
> > users it just "doesn't work" without them manually having to write scri=
pts
> > to handle the ACPI even themselves.
>=20
> Distributions will need to accommodate to the way d80211 stack works
> anyway, so I see no problem with this.
>=20
> > B. should we be firing an ACPI event and getting the distro's to add sc=
ripts
> > so when this event is fired they bring down all the wireless interfaces.
>=20
> Voting for this. It brings more flexibility.
>=20
> This is not a problem of your card only. Is there a standard ACPI
> rf-kill event?

Not sure actually. the approach rt2x00 takes is sending an event ACPI_TYPE_=
EVENT
with as argument a 0 or 1 depending on the new state of the button.
But I don't know if there is another event that would be more suitable for =
a hardware button.

--nextPart1173420.JVXhNmTFHm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEaIlWaqndE37Em0gRAgklAJ99p0qjiludMvEMAXSH6li0E/vZmQCfXKwc
kd2X/VpFHk9qv69Odp6f+2s=
=CG6e
-----END PGP SIGNATURE-----

--nextPart1173420.JVXhNmTFHm--

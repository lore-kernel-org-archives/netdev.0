From: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: Re: PCI: make pci_restore_state return void
Date: Mon, 06 Dec 2010 09:46:50 +1100
Message-ID: <1291589210.8514.17.camel@concordia>
References: <1291160606-31494-1-git-send-email-jon.mason@exar.com>
Reply-To: michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-hIo3ss+mqY7LCWIJJSeq"
Cc: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Gallatin <gallatin-vV262kQ/Wyo@public.gmane.org>,
	Brice Goglin <brice-vV262kQ/Wyo@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Steve Hodgson <shodgson-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brian King <brking-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Anil Ravindranath <anil_ravindranath-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jaya Kumar <jayakumar.alsa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	boyod.yang-S9cbI//bT0v8C245oKUbwW/U75nxZMCp@public.gmane.org
To: Jon Mason <jon.mason-0FX2CSrisTk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1291160606-31494-1-git-send-email-jon.mason-0FX2CSrisTk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-hIo3ss+mqY7LCWIJJSeq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-11-30 at 17:43 -0600, Jon Mason wrote:
> pci_restore_state only ever returns 0, thus there is no benefit in
> having it return any value.  Also, a large majority of the callers do
> not check the return code of pci_restore_state.  Make the
> pci_restore_state a void return and avoid the overhead.

It does kind of make me nervous that (basically) no one ever checks the
return code from the PCI config space accessors, even though in theory
they can fail. This code being but one example.

/end random comment :)

cheers


--=-hIo3ss+mqY7LCWIJJSeq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkz8FloACgkQdSjSd0sB4dIPhwCeNnj0SmUov+MFuxEIOmKoioHa
Tl4An1+jVELgYgfllAqQnNuGjRly4Xgt
=nazf
-----END PGP SIGNATURE-----

--=-hIo3ss+mqY7LCWIJJSeq--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

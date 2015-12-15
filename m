From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 4/4] VSOCK: Add Makefile and Kconfig
Date: Tue, 15 Dec 2015 16:19:24 +0800
Message-ID: <20151215081924.GD30291@stefanha-x1.localdomain>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
 <1449662633-26623-5-git-send-email-stefanha@redhat.com>
 <87fuz8q4xf.fsf@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EP0wieDxd4TSJjHq"
Cc: kvm@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	matt.ma@linaro.org, virtualization@lists.linux-foundation.org,
	Asias He <asias@redhat.com>
To: Alex =?iso-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fuz8q4xf.fsf@linaro.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EP0wieDxd4TSJjHq
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 11, 2015 at 05:19:08PM +0000, Alex Benn=E9e wrote:
> > +config VHOST_VSOCK
> > +	tristate "vhost virtio-vsock driver"
> > +	depends on VSOCKETS && EVENTFD
> > +	select VIRTIO_VSOCKETS_COMMON
> > +	select VHOST
> > +	select VHOST_RING
> > +	default n
> > +	---help---
> > +	Say M here to enable the vhost-vsock for virtio-vsock guests
>=20
> I think checkpatch prefers a few more words for the feature but I'm
> happy with it.

I have expanded the description.

> > diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
> > index 14810ab..74e0bc8 100644
> > --- a/net/vmw_vsock/Kconfig
> > +++ b/net/vmw_vsock/Kconfig
> > @@ -26,3 +26,21 @@ config VMWARE_VMCI_VSOCKETS
> >
> >  	  To compile this driver as a module, choose M here: the module
> >  	  will be called vmw_vsock_vmci_transport. If unsure, say N.
> > +
> > +config VIRTIO_VSOCKETS
> > +	tristate "virtio transport for Virtual Sockets"
> > +	depends on VSOCKETS && VIRTIO
> > +	select VIRTIO_VSOCKETS_COMMON
> > +	help
> > +	  This module implements a virtio transport for Virtual Sockets.
> > +
> > +	  Enable this transport if your Virtual Machine runs on
> >  	  Qemu/KVM.
>=20
> Is this better worded as:
>=20
> "Enable this transport if your Virtual Machine host supports vsockets
> over virtio."

Good idea.  Will fix in the next revision.

--EP0wieDxd4TSJjHq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWb80MAAoJEJykq7OBq3PIAlYIAJfuwM68UPCFwpLS2ZcJQOPf
v5TH/5uIvrnzRtWW1EPJA2eSxAGTKywGPPtUjrlqh3CVTfmRMqFxCSkwfvfTOwcj
mwfemQHg9GPioDNyZb/ZMw+jZMAwhExB0KCdECXZoUoh8X0AknfBVyxoTYq4XduL
Sg3L8r2kQUQqGVPENR/vC950M0ValNEc8VSa7wipnX6W9gTZdrWEVakyZdo8Iv88
vV62QkIkXIQdzdu38KOLTBO1qEGOrON1m4t6YHquXNkJQrHmR7kz9kwIJQEWgEgK
8w6x1F2nRGFBCz5xe56XMYJmBWOS1AMo0eI/6nmydKyFrCNERK7jrsexkebMTHU=
=MfM0
-----END PGP SIGNATURE-----

--EP0wieDxd4TSJjHq--

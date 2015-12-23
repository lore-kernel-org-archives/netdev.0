From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Wed, 23 Dec 2015 11:09:56 -0500
Message-ID: <567AC754.5020508@redhat.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="rVAhAUIrQjWONLcjIP1HTffQqlkGvDgxf"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-1-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rVAhAUIrQjWONLcjIP1HTffQqlkGvDgxf
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/21/2015 06:13 PM, Faisal Latif wrote:
> This (V1) series contains the addition of the i40iw.ko driver after
> incorporating the feedback from Christoph Hellwig and Joe Perches for
> initial series.
>=20
> This driver provides iWARP RDMA functionality for the Intel(R) X722 Eth=
ernet
> controller for PCI Physical Functions. It also has support for Virtual
> Function driver (i40iwvf.ko), which that will be part of separate patch=

> series.
>=20
> It cooperates with the Intel(R) X722 base driver (i40e.ko) to allocate
> resources and program the controller.
>=20
> This series include 1 patch to i40e.ko to provide interface support to
> i40iw.ko. The interface provides a driver registration mechanism, resou=
rce
> allocations, and device reset coordination mechanisms.
>=20
> This patch series is based on Doug Ledford's k.o/for-4.5.

My apologies Faisal.  I had pushed that branch to github to get 0-day
testing, but hadn't committed it to my k.o tree as it wasn't fully
finalized (I was waiting for Or to get his chance to respond to it).
Once Or responded, I ended up taking his patchset instead, which means
you need to adjust your patches accordingly.

>=20
> Anjali Singhai Jain (1)
> net/ethernet/intel/i40e: Add support for client interface for IWARP dri=
ver
>=20
> Faisal Latif(15):
> infiniband/hw/i40iw: add main, hdr, status
> infiniband/hw/i40iw: add connection management code
> infiniband/hw/i40iw: add puda code
> infiniband/hw/i40iw: add pble resource files
> infiniband/hw/i40iw: add hmc resource files
> infiniband/hw/i40iw: add hw and utils files
> infiniband/hw/i40iw: add files for iwarp interface
> infiniband/hw/i40iw: add file to handle cqp calls
> infiniband/hw/i40iw: add hardware related header files
> infiniband/hw/i40iw: add X722 register file
> infiniband/hw/i40iw: user kernel shared files
> infiniband/hw/i40iw: virtual channel handling files
> infiniband/hw/i40iw: Kconfig and Kbuild for iwarp module
> infiniband/hw/i40iw: Add entry for I40IW rdma_netlink.h
> infiniband/hw/i40iw: changes for build of i40iw module
>=20
> Changes done from initial version to V1 are following.
>=20
> Feedback received from Christoph Hellwig
> *Remove pointless braces -improved after code review and changing
> *kmap()/kunmap() - made it very short lived
> *less casts -improved=20
> *Remove unused routine stubs - done
> *no initialize to 0 or NULL when struct field were zeroed - done
> *define UNREFERENCED_PARAMETER not needed -done
> *remove define I40eE_MASK  -done
> *rd32(), wr32() make them inline -done
> *readq() use magic in linux/io-64-nonatomic-lo-hi.h -done
> *SLEEP() define -done by removing it
> *entry in rdma_netlink.h for I40IW should be in proper location
> 	and separate patch -done
>=20
> Feedback received from Joe Perches
> *series to respuun re-spun against next - done with
> 	Doug's Ledford's k.o/for-4.5
> *Change to i40e client patch regarding mailing list - this is consisten=
t
> 	with other i40e files.
> *Removed error from i40iw_pr_err() -done
> *cqp_request() change from bitfields to bool -done
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--rVAhAUIrQjWONLcjIP1HTffQqlkGvDgxf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWesdUAAoJELgmozMOVy/dujwP/RdjfQYWmPrQEMfiBVOoiojb
9mXT8Kv8XPlA8ZpvRoyMHN1HP1UfLYIfu2wJjoS3TdkFkUfdHLym3YzfIgmWYZgB
OeN9etHPIkP3DdodROZwK7s48zbB+uZetypwZ/+SYkAIJxgPQft85YkgRHyL1H7T
hcqY/DcNBVhlaV+0WrXmLo7CtEKuvdM6E01uY2+gZimJsS0uMRJNFnNnddq+v/0E
g451EVsipP9h+4Tc1oxE5/IY5PiZg3diLEEEEXbKrRLwY00TSkRlSu5fDjHZNiGB
Vnmm39P41YPNFbnjcLif7bT155Srbcy0vt2K369f1ThXQhHNeFhgVCFMcxcvmTjz
94HiPP5zyGvDmSDNFkfzoh168XHhLfLP+uXB0rPoPTaxcWzYyw3rrp9f/1g/PUXb
KMix6f+3siDdi/4fGLBvE9erMpvjPcKPe6EjbwKMIXT3Kfd3RxgbisIAtTN7hBVU
aaK/na66B6JIrJTdx19++Bz1HAKeDe3lZgJtU+pWfTYbrqPiFieNeV6FR9N28O44
7zQxAFBEmvHuR4jhUZaCgIZlbDHkaZZv6TwPCyAdUtat2R0jA39DCNQnEonq+rGV
EHe3I0IZ3hENtGPedA2S3QJGKoN1Eb7RtKXgBHx7tQOQsWxnVkjgDsSqGAFCSkqO
PDPSW6QHuKwrnBFfaOvR
=UnjH
-----END PGP SIGNATURE-----

--rVAhAUIrQjWONLcjIP1HTffQqlkGvDgxf--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

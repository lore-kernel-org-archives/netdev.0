From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 12 Sep 2016 19:39:28 +0300
Message-ID: <20160912163928.GK8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="IJAclU0AInkryoed"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473696465-27986-1-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IJAclU0AInkryoed
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 12, 2016 at 07:07:34PM +0300, Ram Amrani wrote:

>  include/linux/qed/common_hsi.h                 |    1 +
>  include/linux/qed/qed_if.h                     |    9 +-
>  include/linux/qed/qed_ll2_if.h                 |  140 +
>  include/linux/qed/qed_roce_if.h                |  604 ++++
>  include/linux/qed/qede_roce.h                  |   88 +
>  include/linux/qed/rdma_common.h                |    1 +

Something not directly related to your patches, but they brought my
attention to the fact that all these new (and old) rdma<->net devices
are polluting include/linux

Filtered output:
=E2=9E=9C  linux-rdma git:(topic/fixes-for-4.8-2) ls -dl include/linux/*/
drwxrwxr-x  2 leonro leonro  4096 Aug 30 16:27 include/linux/hsi/
drwxrwxr-x  2 leonro leonro  4096 Sep 12 19:08 include/linux/mlx4/
drwxrwxr-x  2 leonro leonro  4096 Sep  7 15:31 include/linux/mlx5/
drwxrwxr-x  2 leonro leonro  4096 Sep  8 17:46 include/linux/qed/

Is this the right place for them?

Thanks

--IJAclU0AInkryoed
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX1tpAAAoJEORje4g2clinlqoP/2bZIzFHQx+ajhuGFIC0lPoJ
B75PlrRmbFS4T2D4rCIlPhcrIlW48WMy3Up0Rr0pbw6sAkv3DImODMF+wnIz3PPU
4H1rP112Yi4AIzNGM3yMEa91nXhJeJmVCgiGm4MmPVPGkc1Im5rfq2fhsDXIFfof
Gqt4/o3zFwJUVf8cQjdezJaEr91/DkW5H+rP3epQ1Svu+ajK4c5e5ZM1aBEDXLpq
5vXHDXRZ4O53dyQdxruVDUAQuMiZY3VUi3/4lxTEs4NDxvbb12xaF12q6/YIaI1V
dRg7fd9tpdeZS67r8kdznTfwjQS/jf2iRcwCCNHlpE+TI2wvunP498q6hkTdN4HA
pQ2JLQ7zfR8qg/CCvyDTprXy8kLjS51YiNH+PGlUmoibBCssg8szuCo+Hxs2FNx6
RYmykq/yeBT2o7CgYNJAl4sGmflVTSMbf47VEJYncAmY1t1EuhyVjhV9wAspzoA8
KK7NZsW/q5C6kXW0aQuHdsy06QJvYpfRFkwMYWh5aUQuoDzKxDz1VL7HO+62Zsmx
T0m6sGljqJPUfYffshtCBWN4cl36qcCMn2nspmCcS1HYrnUHNXPgiNbzXvA1GGMz
LdOxAAHg9nBvqOID5yRail67Qa+X4xZFh57vAY1YpYWkHzTtziNWkhjZaH26MEl4
S5p2c+z3GnT+my7nhWqV
=2uc3
-----END PGP SIGNATURE-----

--IJAclU0AInkryoed--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: Use sock_diag instead of procfs for new address families?
Date: Wed, 19 Jul 2017 09:48:12 +0100
Message-ID: <20170719084812.GB5628@stefanha-x1.localdomain>
References: <20170718161806.GA21151@stefanha-x1.localdomain>
 <20170718095838.18afb608@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="neYutvxvOLaeuPCA"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jorgen Hansen <jhansen@vmware.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44984 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753195AbdGSIsO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 04:48:14 -0400
Content-Disposition: inline
In-Reply-To: <20170718095838.18afb608@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--neYutvxvOLaeuPCA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 18, 2017 at 09:58:38AM -0700, Stephen Hemminger wrote:
> On Tue, 18 Jul 2017 17:18:06 +0100
> Stefan Hajnoczi <stefanha@redhat.com> wrote:
>=20
> > I am implementing userspace access to socket information for AF_VSOCK.
> > A few hours into writing and testing a /proc/net/vsock seq_file I
> > noticed that ss(8) prefers NETLINK_SOCK_DIAG over procfs.
> >=20
> > Before potentially wasting time implementing a legacy interface that
> > won't be accepted, I thought it might be good to ask :).
> >=20
> > Which approach is preferred?
> > 1. New address families must implement only sock_diag.
> > 2. Both sock_diag and procfs must be implemented.
> > 3. Implement whichever interface you prefer.
> >=20
> > Thanks,
> > Stefan
>=20
> You are correct, I am unlikely to take any new code using /proc
> in ss.

Thanks Stephen and David, will switch to sock_diag.

Stefan

--neYutvxvOLaeuPCA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZbxzMAAoJEJykq7OBq3PITcYIAJcDaRRGu+X+aCr+opGXIDiL
Aj249VsIPtuLH/jtV0LWOZyj0JjmaN1/hmhyBi6Wts8V9CTTLqrT657QtLJVhW8u
R1NIaE8V9k57XdCpfWliTmkQGBUJf3cAb5UoENz/1717MjlIzdabq1ftufehYOgX
OLGmb9m9AsOj9Qlp6/5Tqy6dIBdxrcipIiPexf+BJId9gm2d78J9gg8TvHXCR26Z
zfY7YVEcv0MNBCNYqBXL908q6coJ6ekQieASOVIOOuoDmPSctTxJ2lg11YNvDImS
2V+cD5vab3B0anZuF9E1/Bpuedgjqz5Zkjl2iEll1i8MzEdZerJCDr2tYZMEC9Q=
=oKb0
-----END PGP SIGNATURE-----

--neYutvxvOLaeuPCA--

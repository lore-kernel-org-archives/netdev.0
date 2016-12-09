From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v3 4/4] vsock: cancel packets when failing to connect
Date: Fri, 9 Dec 2016 10:17:56 +0000
Message-ID: <20161209101756.GC18260@stefanha-x1.localdomain>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-2-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-3-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-4-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-5-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="adJ1OR3c6QgCpb/j"
Cc: Stefan Hajnoczi <stefanha@redhat.com>, netdev@vger.kernel.org,
        Jorgen Hansen <jhansen@vmware.com>,
        David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481217156-7160-5-git-send-email-bergwolf@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--adJ1OR3c6QgCpb/j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 09, 2016 at 01:12:36AM +0800, Peng Tao wrote:
> Otherwise we'll leave the packets queued until releasing vsock device.
> E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
> will get the connect requests from failed host sockets.
>=20
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

Please do not include Reviewed-by: if the patch has undergone
substantial changes.

I am happy with this latest version:
Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--adJ1OR3c6QgCpb/j
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSoTUAAoJEJykq7OBq3PIgAwH/jje5hhZHiuPT2OchtkAHPtX
KnKvv+lZrliEmFwqcQNLQ5zt1FVXLc+WpSfsiFl70nJlek3JUcE+Ww+KteGp0QCw
xBSpFqIS1/KnHjs5CsqPBf3U4yk0PcFQSKfprBSRIkPjNFYmRMG3bxaIyOKHQftd
2oStgmMoRQSoNkpv/5YEvypY7XEBg3yOW3abvuN+NLFmuB2UV7WE4lzZHvVXrNzp
EJMG/AEQEzNbDYP8Pbtj/F2giakLElYFmHfh1EQTe+9BWLRWKKSJsEzx6HHNEht+
xVWUVuPIcfRiZrknkZAWfPlVyPTAxn8u/JLNoOsHwc18n7AQsmi8XJ54wiszbD4=
=NiBy
-----END PGP SIGNATURE-----

--adJ1OR3c6QgCpb/j--

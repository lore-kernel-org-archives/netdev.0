From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 12 Dec 2013 11:49:59 +1100
Message-ID: <20131212114959.b08ea67fe5624ed6fb392c52@canb.auug.org.au>
References: <20131212111539.cff1b2efe934c5cd7abbb822@canb.auug.org.au>
	<20131211.193639.2058525533631918382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__12_Dec_2013_11_49_59_+1100_l7Ft+cYyYJQzS3ag"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jasowang@redhat.com,
	wuzhy@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131211.193639.2058525533631918382.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__12_Dec_2013_11_49_59_+1100_l7Ft+cYyYJQzS3ag
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 11 Dec 2013 19:36:39 -0500 (EST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 12 Dec 2013 11:15:39 +1100
>=20
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/macvtap.c between commit ce232ce01d61 ("macvtap: signal
> > truncated packets") from the net tree and commit 55ec8e25cd97 ("macvtap:
> > remove unused parameter in macvtap_do_read()") from the net-next tree.
> >=20
> > I fixed it up (see below) and can carry the fix as necessary (no action
> > is required).
>=20
> The net-next commit in question was reverted last night.

Actually, the only relevant revert in the net-next tree I fetched this
morning is commit de2aa4760b45 (Revert "macvtap: remove useless codes in
macvtap_aio_read() and macvtap_recvmsg()") which reverts 41e4af69a598,
not the commit mentioned above.  Unless you haven't pushed out the
net-next tree with a later revert ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__12_Dec_2013_11_49_59_+1100_l7Ft+cYyYJQzS3ag
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSqQg7AAoJEMDTa8Ir7ZwVjpAP/AyN0v9W5YtbUqPpOlQvIUAB
OjX+lGyujzgnTtXx9yK6iydMe/w7UfIr6DpZJEZmvHLWtpokloVub0XAJ7ryIFKz
2O5t45imCX5PWkydKif6hs3/6TkHvpCZJ2pXmiYisci44RhcuGyfNfQ8vDPkjteQ
N4ToUNLGJKuzvccxiufesygOBdbcrAtCIJNw/IiyRClxjGzi7pUcwgWigLf8W3bT
p/xOhFPO8A5Ny2KjtOGEuxxZTg2ecqrOf1oO2TB5GL7qpnInf/dNjE0nQgxq/HPW
aRPbZUHJUbXC+2JZ9M1zaV3atW3o8Ely1+puIeLPM6csLuDEuEiFn22upVcwjraw
aeL9yXq6B7S/sil65I/e5vGxuYj0xCwimEIqm7OHXBVx8LxSNivk3MTTnc556FjF
rPjVx+meG3z7zumODmAl3jDQhVkBTgqj0D7YmjisRLWyC1fx6Im65Ae/dhuBtfm2
Ma8Y1vrXSLdjNOBkhKNyZK+TRG9hUv5jwHF+AW9TOFRbXn8vMD5/VUxA8ZkTGpNA
F1OXpRCyh/C8+2DoAaChC8M98ryzJzsB7yWmYOyHMUjSlmoM/2rIPvefO4tN93VA
ve6VbXzFDk7Jcx/skRzdrJ81nPZMCDNnyD+yb6HKtA0N8DxzGETuKoJj5oTayx5V
GJl0KnBAhN2KzYUrvhyr
=WM7r
-----END PGP SIGNATURE-----

--Signature=_Thu__12_Dec_2013_11_49_59_+1100_l7Ft+cYyYJQzS3ag--

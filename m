From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the mips tree
Date: Thu, 24 Jan 2013 12:03:42 +1100
Message-ID: <20130124120342.242bd830dff336322018e0be@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Jan_2013_12_03_42_+1100_h_qRkXBuoT/Ylq/J"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__24_Jan_2013_12_03_42_+1100_h_qRkXBuoT/Ylq/J
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
arch/mips/include/uapi/asm/socket.h between commit c4ff4842935c ("MIPS:
Whitespace cleanup") from the mips tree and commit 055dc21a1d1d
("soreuseport: infrastructure") from the net-next tree.

Also, that net-next tree patch can't be right (it removes an "#if 0" but
not the matching "#endif") - I fixed that as well.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/mips/include/uapi/asm/socket.h
index cc208f9,7e27236..0000000
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@@ -28,12 -28,11 +28,10 @@@
  #define SO_LINGER	0x0080	/* Block on close of a reliable
  				   socket to transmit pending data.  */
  #define SO_OOBINLINE 0x0100	/* Receive out-of-band data in-band.  */
- #if 0
- To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse=
.	*/
- #endif
+ #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 -#endif
 =20
  #define SO_TYPE		0x1008	/* Compatible name for SO_STYLE.  */
 -#define SO_STYLE	SO_TYPE	/* Synonym */
 +#define SO_STYLE	SO_TYPE /* Synonym */
  #define SO_ERROR	0x1007	/* get error status and clear */
  #define SO_SNDBUF	0x1001	/* Send buffer size. */
  #define SO_RCVBUF	0x1002	/* Receive buffer. */

--Signature=_Thu__24_Jan_2013_12_03_42_+1100_h_qRkXBuoT/Ylq/J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRAIhuAAoJEECxmPOUX5FEQ1YP/jtJ2cJ4Ru6Zm+3/krE17wOR
1Na22SozGiHSl191c7rz+ZbTBMw6xO+OI9Qev9uADNlxrCqTJBTYq4jJ+B5LNQoe
F9fCddBIf4uquOvs7l8PojK84DOWD5O+e+MWOmpGk98HRRG0k/vv5b0uaSB2SEwG
nTkNtGPmXHSFqKi9Kl6yPppo44I20G+nTfgJjpcy9V6f41NAEtWL7Td+pqwSL0pD
WDHodCPU85AMbPXV977lFSZ4hVmQv4CTkMYuyM11cJaDfa7/tSaNIiePHo4lSAnK
UblxpLs56b1e826HdNSfIgvE3MtPBtxEiwsKjk9F+J5a+OBKq2XXVB72h6JCVOwT
uHPDJhiZGzZW7UjcjMyIhlxuF8TZEjQRmw66F47/ITp19TtaPcOO/mQ+xiw5WFiv
jr9XDEIV5AnGk4SztxuZ7ydw2MeQARsTPgNlDFXVZlNSkyDWaXjDTaaaFCdMy7sS
7oKXHvam1qfi/rXRpd9OmmKb8f0j9vBBFrXxnuB5daEvnhvfc/oFFCjj4nai/uON
7mZdxpllmWfimXP0Nwv6L+74toKT3Tzn3pjXqxMXgIzdsyat/mL6P7+S12SBzFgc
H7iKF/a0VPIo79LuhPfhZ2mLAhEEIwjwRHP6bSRHu5axH9Ph4hHND/791IyL8I1Q
u+wAyaypePJ+qTZ3B2By
=16p1
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Jan_2013_12_03_42_+1100_h_qRkXBuoT/Ylq/J--

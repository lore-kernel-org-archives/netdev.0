From: Henrik Brix Andersen <brix@gentoo.org>
Subject: Re: [PATCH] hostap: allow flashing firmware
Date: Thu, 5 Jan 2006 12:34:58 +0100
Message-ID: <20060105113458.GC14998@osgiliath.brixandersen.dk>
References: <1135984946.17805.21.camel@dv> <20060105051857.GO8939@jm.kir.nu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1931543265=="
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: hostap@shmoo.com
In-Reply-To: <20060105051857.GO8939@jm.kir.nu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org


--===============1931543265==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NU0Ex4SbNnrxsi6C"
Content-Disposition: inline


--NU0Ex4SbNnrxsi6C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 04, 2006 at 09:18:57PM -0800, Jouni Malinen wrote:
> I'm not completely against this change, but that scary comment is there
> on purpose and it is not fully obsolete. It is still possible to get
> HFA3841 cards into state which require hardware modifications to recover
> from (i.e., they are as good as dead for most users). Taken into this
> account, I would prefer that the help text for HOSTAP_FIRMWARE_NVRAM
> would include a warning about the potential issues of using incorrect
> firmware images. In most cases, RAM (volatile) download can be used to
> upgrade the firmware without having to modify the flash contents. This
> is also what the current Windows drivers are doing.

I would welcome such a warning as well - perhaps make
CONFIG_HOSTAP_FIRMWARE_NVRAM depend on CONFIG_EXPERIMENTAL as well?

Regards,
Brix
--=20
Henrik Brix Andersen <brix@gentoo.org>
Gentoo Metadistribution | Mobile computing herd

--NU0Ex4SbNnrxsi6C
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: GnuPG signed

iD8DBQFDvQRiv+Q4flTiePgRAlCuAKC4HG0k/iVzxBJBfvcSdGtr4Y8hpQCeJBWV
jIszB6HooEgZdyRDDblBxVE=
=4x/Y
-----END PGP SIGNATURE-----

--NU0Ex4SbNnrxsi6C--

--===============1931543265==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
HostAP mailing list
HostAP@shmoo.com
http://lists.shmoo.com/mailman/listinfo/hostap

--===============1931543265==--

From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 15:08:37 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021130837.GE3551@sunbeam.de.gnumonks.org>
References: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
	<20041021091632.GB3551@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410211215580.19600@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k4f25fnPtRuIRUb3"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410211215580.19600@filer.marasystems.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--k4f25fnPtRuIRUb3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 12:25:35PM +0200, Henrik Nordstrom wrote:

> The MARK bit-wise operations is also available for CONNMARK and could in=
=20
> theory be included in CONNMARK when submitted to the kernel=20

Yes, but doesn't the patch I just submitted to DaveM include all the
required functionality?  both ipt_connmark and ipt_CONNMARK have a
'mask' parameter in ther {match,targ}info struct.

> I am fine either way.

If you think there's something (in the kernel) missing for bit-wise
operations of CONNMARK, please let me know and send a patch.  Thanks.

> Regards
> Henrik

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--k4f25fnPtRuIRUb3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd7TVXaXGVTD0i/8RAhooAKCEo2GbrJfSJdd5vZ+r41oDqNb8yQCfThBa
hBF/5WrzzHKDx/CiZxa0tN4=
=qV0h
-----END PGP SIGNATURE-----

--k4f25fnPtRuIRUb3--

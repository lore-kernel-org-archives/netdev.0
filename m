From: Udo Steinberg <udo@hypervisor.org>
Subject: Re: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 17:41:38 +0100
Message-ID: <20111211174138.79e51fe8@x220.fritz.box>
References: <4EE4AEF4.2080702@udo.edu>
	<4EE4DB55.4090804@udo.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/sL2Lv1L8_BpXVl/2_iv/Jqx"; protocol="application/pgp-signature"
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EE4DB55.4090804@udo.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/sL2Lv1L8_BpXVl/2_iv/Jqx
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,

The patch fixes the following bug:
http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2326

If the patch introduces a regression for you, then the problem needs to be
investigated further. Reverting the patch will reintroduce an already fixed
problem for others.

Cheers,

	- Udo

On Sun, 11 Dec 2011 17:33:25 +0100 Andrej Gelenberg (AG) wrote:

AG> Hello,
AG>=20
AG> the original commit 34a5b4b6af104cf18eb50748509528b9bdbc4036 in upstrea=
m (v3.2.0-rc5) break the driver too. Please revert it, before the release. =
Patch for 3.2-rc5 attached.
AG>=20
AG> Regards,
AG> Andrej Gelenberg
AG>=20
AG> On 12/11/2011 02:24 PM, Andrej Gelenberg wrote:
AG> > Hello,
AG> >
AG> > there in an regression in kernel release v3.1.5. Commit
AG> > 43c308bd8d0a3e7d98c5abcd41a4a3fada3d198f "iwlwifi: do not re-configure
AG> > HT40 after associated" break iwlagn driver for Intel Corporation
AG> > Centrino Ultimate-N 6300 (rev 35) on my Thinkpad t510. I still can
AG> > connect to the AP, but i can't pin or access anything. Reverting that
AG> > commit solved the Problem. I attached the patch.
AG> >
AG> > Regards,
AG> > Andrej Gelenberg
AG>=20


--=20
Dipl.-Inf. Udo Steinberg
Technische Universit=E4t Dresden             http://os.inf.tu-dresden.de/~u=
s15
Institute of Systems Architecture          Tel: +49 351 463 38401
D-01062 Dresden                            Fax: +49 351 463 38284

--Sig_/sL2Lv1L8_BpXVl/2_iv/Jqx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7k3UMACgkQnhRzXSM7nSk05ACfdtzowFZoQhMoRz4slHqw0HFg
BUYAnRrNTrMgUQkVdlnYeG3LSkZuN/df
=73xd
-----END PGP SIGNATURE-----

--Sig_/sL2Lv1L8_BpXVl/2_iv/Jqx--

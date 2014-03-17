From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Mon, 17 Mar 2014 21:13:40 +1100
Message-ID: <20140317211340.7beed734d3e3825f31520776@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Mar_2014_21_13_40_+1100_=oyqgGyVeVQX_c8e"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Ertman <davidx.m.ertman@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Mar_2014_21_13_40_+1100_=oyqgGyVeVQX_c8e
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (sparc64 defconfig)
failed like this:

drivers/net/ethernet/intel/e1000e/netdev.c:7079:13: error: 'e1000e_pm_suspe=
nd' undeclared here (not in a function)
drivers/net/ethernet/intel/e1000e/netdev.c:7080:13: error: 'e1000e_pm_resum=
e' undeclared here (not in a function)
drivers/net/ethernet/intel/e1000e/netdev.c:7082:11: error: 'e1000e_pm_thaw'=
 undeclared here (not in a function)

Caused by commit 2800209994f8 ("e1000e: Refactor PM flows") from the
net-next tree.

I reverted that commit for today (and 63eb48f151b5 "e1000e Refactor of
Runtime Power Management" that conflicts with the revert).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__17_Mar_2014_21_13_40_+1100_=oyqgGyVeVQX_c8e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTJsrZAAoJEMDTa8Ir7ZwVKQIP/RhIbagxqqg15BD1e+f/O3ID
3Eop6tM7FbA7HMlh8oso80+pG5CnlclodA8jgezeArzsBdZquMlKf/6B+rsqCCeP
BDsWkmgf1s/2bqYtzosWLmTZOQw1ob3oz/QrhaWXQFMOUjzJBAeeds1XeMRQIWFB
Y0E2tYwL+SLt+k8vutu4DKdATHKhwxDt3B0ZQnEQhbkrQdJNtIlSoKkea2ABoD85
jls0hh4PkQPUC5459H5CYOSsPnq0YgTe9vGvzy1xV+H1BsKnlkNJHoUjoT0oaWHX
3b2HKGsXPm83wgbhgSm6i5u/SwmwItobvJFjD/MWlCtsV0IBsWF4izuDh3L5HAGA
XfAO5cWrAh9mEawZF6bQ7qtiIZIPk8kQigQk1P3UP43NekHcpYfMoqk/GJ/TYtzZ
2sBxWihh1RV+Q/XEvsi1RFHXaCy6CZCeNNqb+AR0nXEtsMTxGcoOFTup4EMhf+14
8hZsDtV9R9vt2OTIbc5ksiG0qpNPJjKcMQjt1tsseIbIHCZ/sNXuIFGGxssr9zm1
kmb4MsbV4pFjE81qSkMWN2Xq5T77v4qJBaBwbn7l84/5sb52zcA9c3Qn1/QPo8bo
h+ipLt1F8MDJyEmwuWL5a36M3mDgxE4ZWOPEXAdkSMdA2ayVJm/FkYVZ++wZ7MZa
wEhXSbxYkD2GkxtjAu3f
=zJ54
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Mar_2014_21_13_40_+1100_=oyqgGyVeVQX_c8e--

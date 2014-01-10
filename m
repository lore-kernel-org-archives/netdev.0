From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH-next] intel ethernet: fix s390 build
 failure due to implicit prefetch.h
Date: Fri, 10 Jan 2014 11:56:31 -0800
Message-ID: <1389383791.2844.9.camel@jtkirshe-mobl>
References: <1389382096-17122-1-git-send-email-paul.gortmaker@windriver.com>
	<20140110.145229.334617909103085999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3020326127906490610=="
Cc: sibai.li@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	paul.gortmaker@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140110.145229.334617909103085999.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3020326127906490610==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bbaohOb4czSa7b1I6H9w"


--=-bbaohOb4czSa7b1I6H9w
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-10 at 14:52 -0500, David Miller wrote:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Fri, 10 Jan 2014 14:28:16 -0500
>=20
> > As of commit 7f12ad741a4870b8b6e3aafbcd868d0191770802 ("i40evf: transmi=
t
> > and receive functionality") the s390 builds (allyesconfig) fail with:
> >=20
> > drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function 'i40e_clean_=
rx_irq':
> > drivers/net/ethernet/intel/i40evf/i40e_txrx.c:818:3: error: implicit de=
claration of function 'prefetch'
> > make[5]: *** [drivers/net/ethernet/intel/i40evf/i40e_txrx.o] Error 1
> >=20
> > due to an implicit assumption that the prototype from linux/prefetch.h
> > will be present.
> >=20
> > Cc: Mitch Williams <mitch.a.williams@intel.com>
> > Cc: Greg Rose <gregory.v.rose@intel.com>
> > Cc: Sibai Li <sibai.li@intel.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>=20
> I hope the Intel folks will pick this up quickly and push it to me.

Yep, Aaron has it in the queue and it is being reviewed and tested
currently.

--=-bbaohOb4czSa7b1I6H9w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJS0FBvAAoJEOVv75VaS+3OaiQP/1RBFEjZI6eSk4NaKKM618Q+
+TiFPO7JUu8rNejuy6b4STyAD4fwKj8LA36OjlD4G+Lh4PMHBdXoAeL2uBkH+k1j
iEWvkmoJyrmwC6i/a+Nx1s+yyARYTKaCdqo4ktkfSfsqlEUsofhTAZ+ObIX/0zJw
xCytwjrOS541BXpGgfmkFFc60c3GQ2vnMVvdUTwG/GegtU5vy/Fcea0GlIcsnpBk
J4QQzpDcraOgRz0w6Hdaf1E2W8iXt4jfArtAuXzh4MwAtbscJ+eipPt4e60qs9RP
hocg8NlPlniyPHxjNg6siQw5xmYk9R297S3N7XA88XqUvcjTrmN72LOuATNMTVmL
Ezgw93xkok1GVvsXg0Tgft0IOt3n2/R88giui8QRl2ygcBtQJRYhozPQ9K199q0k
TqVaV4phgCIMMqBjt8reiysGBXZ6/UE14sQqyMWaqBf2Noq79LYkyzhlwf7hSh1F
CQAdumQ3/LD4FUaegoc/+7Eh3StDfY2dN6Zx3gr07JE3iicfC85RU/nebrMNOZUB
kQA9FcltUaxZtEsL61BUoW0YhF63nQEIR6wuv7/lFwbR69BvazYiCStNrHdlzzPu
klrnKhh+XgU9oQzMDvlNla69plJm7W3fuc78nwl87ExC+zetcyEJDtqPmaCGJPnb
8yzFiKQYZl2s+MbQi/E1
=vUYJ
-----END PGP SIGNATURE-----

--=-bbaohOb4czSa7b1I6H9w--



--===============3020326127906490610==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
--===============3020326127906490610==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3020326127906490610==--

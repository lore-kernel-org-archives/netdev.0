From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 5/7] ixgbe: use
 pcie_capability_read_word() to simplify code
Date: Wed, 04 Sep 2013 02:26:40 -0700
Message-ID: <1378286800.2048.1.camel@jtkirshe-mobl>
References: <1378193715-25328-1-git-send-email-wangyijing@huawei.com>
	<1378193715-25328-5-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4815684086418555300=="
Cc: e1000-devel@lists.sourceforge.net,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, "James
	E.J. Bottomley" <JBottomley@parallels.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Yijing Wang <wangyijing@huawei.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378193715-25328-5-git-send-email-wangyijing@huawei.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4815684086418555300==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FzsLmdWGu8vfr7ZgN+tn"


--=-FzsLmdWGu8vfr7ZgN+tn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-09-03 at 15:35 +0800, Yijing Wang wrote:
> use pcie_capability_read_word() to simplify code.
>=20
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Cc: e1000-devel@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)

Thanks Yijing, I will add it to my queue.

--=-FzsLmdWGu8vfr7ZgN+tn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSJvzQAAoJEOVv75VaS+3OG8IP/iHrGRDmPGoofrbCkgAIj+uL
eCCvun9ymY0BSfGB9Uu9VNB+ryJAIk2H5apldYWeURyoVQxdJVlBJnPTqI3jN1Kw
/DzP+FRUyiRVD9NCW2cRB9ZVzKSlkqOZ/UKtpOwbAh0+rWT/k8T/cvfK1/EMibyh
71w05n1IlXJoDZqKi01M+w3JQJhK3yLwq/pcW4npwxXI864Mg21ExjQqxgd0ABVl
2UJ3LNQ297vfTco4bOXXLtS6Wdtl316iYFG3Ix3YdBK+q5ly4qtHX6UEp1YtaZlv
UMtlEIZu0TDiDzO1srxyroHFcEmB76OmZZnY30huVwx07zbOFP0JuzT4yyWGRIuk
+LBQWMhkJ2c5l74PmejzDfD/Ur4+1dFwi7qs++z2NZJE1IH6L1HZbdPHMm6yq5B8
ZNzV9nsaS0JO6XVJYdtzB/r0jfHhbTuYqYN83eFtW2n6qGYqyj/K+mm1LVJ+WjmS
HTsJxbElwVPbJbt8s7OUNt8EFNogezIiPGzqUAx6+CVHAidN5cxxsu7ueF6LLLNF
MgjlZrWL9a/1mi7pco5JMSLUaQm4Ej3vAm0u2W+hiSfWuNKG9K/9eHHkFqiL7747
A8xDvnxfpfZPKyK97miOeJAL+GXbndeVcjqdNAAc8AW0Q8OuBQcqYmsqyeqIHFWd
+s2B/j2TWlba8UnxQdRE
=YYqR
-----END PGP SIGNATURE-----

--=-FzsLmdWGu8vfr7ZgN+tn--



--===============4815684086418555300==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
--===============4815684086418555300==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4815684086418555300==--

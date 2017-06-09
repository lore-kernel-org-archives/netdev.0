From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed: add qed_int_sb_init() stub function
Date: Fri, 9 Jun 2017 13:44:01 +0000
Message-ID: <BLUPR0701MB2004385885B7ECD40AC806598DCE0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170609103744.3239316-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609103744.3239316-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When CONFIG_QED_SRIOV is disabled, we get a build error:
>=20
> drivers/net/ethernet/qlogic/qed/qed_int.c: In function 'qed_int_sb_init':
> drivers/net/ethernet/qlogic/qed/qed_int.c:1499:4: error: implicit declara=
tion
> of function 'qed_vf_set_sb_info'; did you mean 'qed_mcp_get_resc_info'? [=
-
> Werror=3Dimplicit-function-declaration]
>=20
> All the other declarations have a 'static inline' stub as an alternative =
here, so
> this adds one more for qed_int_sb_init.
>=20
> Fixes: 50a207147fce ("qed: Hold a single array for SBs")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Missed it. Thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

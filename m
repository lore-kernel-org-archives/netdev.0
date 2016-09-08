From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qede: mark qede_set_features() static
Date: Thu, 8 Sep 2016 09:02:25 +0000
Message-ID: <DM5PR11MB172342C66212288F8A5A018697FB0@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473324203-9065-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473324203-9065-1-git-send-email-baoyou.xie@linaro.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We get 1 warning when building kernel with W=3D1:
> drivers/net/ethernet/qlogic/qede/qede_main.c:2113:5: warning: no previous
> prototype for 'qede_set_features' [-Wmissing-prototypes]
>=20
> In fact, this function is only used in the file in which it is declared a=
nd don't need
> a declaration, but can be made static.
> so this patch marks this function with 'static'.
>=20
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

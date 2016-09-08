From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2] qed: mark symbols static where possible
Date: Thu, 8 Sep 2016 12:37:13 +0000
Message-ID: <DM5PR11MB172334FF9A978C71E05A0B4197FB0@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473323117-8772-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Baoyou Xie <baoyou.xie@linaro.org>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473323117-8772-1-git-send-email-baoyou.xie@linaro.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ....
>=20
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
...
> -void qed_get_vport_stats(struct qed_dev *cdev,
> -			 struct qed_eth_stats *stats)
> +static void qed_get_vport_stats(struct qed_dev *cdev,
>+				struct qed_eth_stats *stats)

Looks like you've missed my comment from v1 -
> 1. qed_get_vport_stats() is in use in net-next by qed_main.c starting=20
> with
> 6c75424612a7 ("qed: Add support for NCSI statistics."), so we=20
> shouldn't make it static.

Besides, it still doesn't apply to net-next
[as net-next has function declaration as a single liner].

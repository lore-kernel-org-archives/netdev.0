From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next 1/2] mqprio: Add a new hardware offload type in
 mqprio
Date: Thu, 12 Oct 2017 20:10:28 +0000
Message-ID: <AM0PR0502MB3683208C0F411F67C70BF6B1BF4B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
 <1507775912-22402-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Yunsheng Lin <linyunsheng@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507775912-22402-2-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When a driver supports both dcb and hardware offloaded mqprio, and
> user is running mqprio and dcb tool concurrently, the configuration
> set by each tool may be conflicted with each other because the dcb
(for second 'each') s/each/the

> and mqprio may be using the same hardwere offload component and share
s/hardwere/hardware

> the tc system in the network stack.
>=20
> This patch adds a new offload type to indicate that the underlying
> driver offload prio mapping as part of DCB. If the driver would be
'should' offload

> incapable of that it would refuse the offload. User would then have
> to explicitly request that qdisc offload.

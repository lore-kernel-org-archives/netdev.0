From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: =?utf-8?Q?=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=5BPATCH=5D_set_fake=5Fr?=
	=?utf-8?Q?table's_dst_to_NULL_to_avoid_ker?=	=?utf-8?Q?nel_Oops.?=
Date: Thu, 29 Mar 2012 17:38:59 +0800
Message-ID: <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
 <1333002975.2325.82.camel@edumazet-glaptop>
 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
 <1333011120.2325.354.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1333011120.2325.354.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thks for your mail.

>Check net/bridge/br_netfilter.c and commits e688a6048076 (net: introduce
>DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MTU value
>in PMTU (revised))

This patch already included in kernel-3.3, but for our case, virtual tap device's delayed
Deletion will also cause kernel oops even in kernel3.3.

>Apparently bug is because struct net_bridge is freed while its embedded
>fake_rtable is still used by some packets.

>I am not sure we are allowed to NULLify skb->dst, it might break
>netfilter.

Are you familiar with fake_rtable? I search the source, but only find one op that operate on the MTU.

>Maybe real fix would be to use a non embedded dst.

I agreed with you to, so at least until now this problem still exsits in the latest kernel, I will also look into it,
And try to modify it from the root.

Thanks again.

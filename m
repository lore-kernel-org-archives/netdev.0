From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 13:44:54 +0200
Message-ID: <87d2ddh1zd.fsf@nemi.mork.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	<1404980258-30853-11-git-send-email-teg@jklm.no>
	<87pphdh85q.fsf@nemi.mork.no>
	<CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com>
	(Tom Gundersen's message of "Thu, 10 Jul 2014 12:12:28 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Gundersen <teg@jklm.no> writes:

> The result of
>
> modprobe dummy numdummies=3D2
>
> is to create dummy0 and dummy1, always with the same names.
>
> The result of
>
> ip link add type dummy
>
> is to create dummyX, where X depends on what came before.

Which is no different. That's exacly what happens when
"modprobe dummy numdummies=3D2" creates the two first interfaces.


 ip link add link wwan0 name dummy0 type vlan id 2
 modprobe dummy numdummies=3D2

ends up with dummy1 and dummy2 created by the dummy driver.

You are trying to make up differences that just aren't there.



Bj=C3=B8rn

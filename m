From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: fix vlan_skb_recv()
Date: Sun, 24 Jan 2010 19:52:36 -0800 (PST)
Message-ID: <20100124.195236.40118964.davem@davemloft.net>
References: <4B5C74BF.5060604@gmail.com>
	<20100124201808.2bbbf0b0@neptune.home>
	<4B5CA2CA.4040307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonbons@linux-vserver.org, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753282Ab0AYDw1@vger.kernel.org>
In-Reply-To: <4B5CA2CA.4040307@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 24 Jan 2010 20:43:06 +0100

> [PATCH] vlan: fix vlan_skb_recv()
>=20
> Bruno Pr=E9mont found commit 9793241fe92f7d930
> (vlan: Precise RX stats accounting) added a regression for non
> hw accelerated vlans.
>=20
> [   26.390576] BUG: unable to handle kernel NULL pointer dereference =
at (null)
> [   26.396369] IP: [<df856b89>] vlan_skb_recv+0x89/0x280 [8021q]
>=20
> vlan_dev_info() was used with original device, instead of
> skb->dev. Also spotted by Am=E9rico Wang.
>=20
> Reported-By: Bruno Pr=E9mont <bonbons@linux-vserver.org>
> Tested-By: Bruno Pr=E9mont <bonbons@linux-vserver.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in
	vlan_skb_recv - probably introduced by commit
	9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 15:12:52 +0800
Message-ID: <20100124071252.GA11037@hack>
References: <20100123165657.187c11e4@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bruno =?utf-8?Q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f190.google.com ([209.85.222.190]:50711 "EHLO
	mail-pz0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab0AXHK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 02:10:56 -0500
Content-Disposition: inline
In-Reply-To: <20100123165657.187c11e4@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2010 at 04:56:57PM +0100, Bruno Pr=C3=A9mont wrote:
>Today I tried out 2.6.33-rc5 but always got crashing system:
>
>[   26.390576] BUG: unable to handle kernel NULL pointer dereference a=
t (null)
>[   26.396369] IP: [<df856b89>] vlan_skb_recv+0x89/0x280 [8021q]


What does 'addr2line -e vmlinux 0xdf856b89' say?

Thanks.


--=20
Live like a child, think like the god.
=20

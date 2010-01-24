From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in
	vlan_skb_recv - probably introduced by commit
	9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 15:30:22 +0800
Message-ID: <20100124073022.GB11037@hack>
References: <20100123165657.187c11e4@neptune.home> <20100124071252.GA11037@hack> <20100124071728.GA3993@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Bruno =?utf-8?Q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752912Ab0AXH2V@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100124071728.GA3993@x200>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 24, 2010 at 09:17:28AM +0200, Alexey Dobriyan wrote:
>On Sun, Jan 24, 2010 at 03:12:52PM +0800, Am=C3=A9rico Wang wrote:
>> On Sat, Jan 23, 2010 at 04:56:57PM +0100, Bruno Pr=C3=A9mont wrote:
>> >Today I tried out 2.6.33-rc5 but always got crashing system:
>> >
>> >[   26.390576] BUG: unable to handle kernel NULL pointer dereferenc=
e at (null)
>> >[   26.396369] IP: [<df856b89>] vlan_skb_recv+0x89/0x280 [8021q]
>>=20
>>=20
>> What does 'addr2line -e vmlinux 0xdf856b89' say?
>
>EIP is in module, so it will say nothing.

Oh, ok, then '-e net/8021q/vlan_dev.o'.

--=20
Live like a child, think like the god.
=20

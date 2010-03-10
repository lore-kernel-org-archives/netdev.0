From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.34-rc1] CPU stalls when closing TCP sockets.
Date: Wed, 10 Mar 2010 07:33:28 -0800 (PST)
Message-ID: <20100310.073328.141230852.davem@davemloft.net>
References: <1268116647.2819.64.camel@edumazet-laptop>
	<201003090654.o296sCnh065487@www262.sakura.ne.jp>
	<1268150156.3113.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268150156.3113.12.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Mar 2010 16:55:56 +0100

> Le mardi 09 mars 2010 =E0 15:54 +0900, Tetsuo Handa a =E9crit :
>> Eric Dumazet wrote:
>> > Nothing comes to my mind, I'll try to reproduce this here.
>>=20
>> When stopped at (8), Ctrl-C doesn't work.
>>=20
>> > Is 2.6.33 OK ?
>>=20
>> Yes. 2.6.33 and earlier are OK.
>=20
> OK thanks !
>=20
> I believe commit d218d11133d888f9745802146a50255a4781d37a
> (tcp: Generalized TTL Security Mechanism) might be the bug origin.
>=20
> I am testing following patch, based on latest net-2.6 tree (including
> the LINUX_MIB_TCPMINTTLDROP bit)
>=20
> [PATCH] tcp: Fix tcp_v4_rcv()
>=20
> Commit d218d111 (tcp: Generalized TTL Security Mechanism) added a bug
> for TIMEWAIT sockets. We should not test min_ttl for TW sockets.
>=20
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

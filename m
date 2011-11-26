From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] AF_UNIX: Fix poll locking problem when reading
 from a stream socket
Date: Sat, 26 Nov 2011 16:35:15 -0500 (EST)
Message-ID: <20111126.163515.1110138680165158231.davem@davemloft.net>
References: <1321918525-5078-1-git-send-email-himeraster@gmail.com>
	<1321939381.27077.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: himeraster@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321939381.27077.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 06:23:01 +0100

> Le mardi 22 novembre 2011 =E0 03:35 +0400, Alexey Moiseytsev a =E9cri=
t :
>> poll() call may be locked by concurrent reading from the same stream
>> socket.
>>=20
>> Signed-off-by: Alexey Moiseytsev <himeraster@gmail.com>
 ..
> Fine, the fix is technically correct since we own u->readlock mutex,
> another thread cannot consume the just requeued skb.=20
>=20
> Small note : the words "locking" and "locked" are more used to descri=
be
> the action of taking a spinlock/mutex/rwlock or something, while the =
bug
> you fixed is more about poll() system call being blocked/frozen forev=
er.
>=20
> Thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, with 'lock{ing,ed}' adjusted to 'block{ing,ed}'.

From: Ulrich Drepper <drepper@gmail.com>
Subject: Re: [PATCH v2] Add MSG_WAITFORONE flag to recvmmsg
Date: Fri, 26 Mar 2010 21:58:24 -0700
Message-ID: <a36005b51003262158q32e47244vf9585aae335ac56b@mail.gmail.com>
References: <20100326223530.GA11817@xpc.home> <1269643470.2256.17.camel@edumazet-laptop>
	<84621a61003261555q2c78f6a8o5b438113bed6bd2@mail.gmail.com>
	<a36005b51003261907x7ebe057bt2d541f63f20f632b@mail.gmail.com>
	<20100327021803.GA10866@xpc.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	linux-kernel@vger.kernel.org
To: Brandon L Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100327021803.GA10866@xpc.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 26, 2010 at 19:18, Brandon L Black <blblack@gmail.com> wrot=
e:
> Add new flag MSG_WAITFORONE for the recvmmsg() syscall.
> When this flag is specified for a blocking socket, recvmmsg()
> will only block until at least 1 packet is available. =C2=A0The
> default behavior is to block until all vlen packets are
> available. =C2=A0This flag has no effect on non-blocking sockets
> or when used in combination with MSG_DONTWAIT.
>
> Signed-off-by: Brandon L Black <blblack@gmail.com>

This is useful and looks OK to me.

Acked-by: Ulrich Drepper <drepper@redhat.com>

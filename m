From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: tcp_v6_iff: fix compilation error on CONFIG_IPV6=n
Date: Sun, 19 Oct 2014 11:50:37 -0700
Message-ID: <1413744637.27176.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5443FD47.7040003@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
To: Manfred Schlaegl <manfred.schlaegl@gmx.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5443FD47.7040003@gmx.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-10-19 at 20:04 +0200, Manfred Schlaegl wrote:
> If CONFIG_IPV6=3Dn, then h6 in struct tcp_skb_cb.header is missing wh=
ich
> leads to compilation-errors on tcp_v6_iff like:
>=20
> In file included from net/core/sock.c:140:0:
> include/net/tcp.h: In function =E2=80=98tcp_v6_iif=E2=80=99:
> include/net/tcp.h:738:32: error: =E2=80=98union <anonymous>=E2=80=99 =
has no member named
> =E2=80=98h6=E2=80=99
>=20
> This fix solves the problem by removing tcp_v6_iif, in case of
> CONFIG_IPV6=3Dn.
>=20
> Signed-off-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
> ---

Yes, this was fixed yesterday, thanks.

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
815afe1785da727ee48cd8e63ac4a3ec6c7459b3

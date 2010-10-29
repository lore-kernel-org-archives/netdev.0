From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 22:45:16 +0200
Message-ID: <1288385116.2680.11.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <alpine.LNX.2.00.1010292217390.24561@swampdragon.chaosbits.net>
	 <20101029.134058.246543591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jj@chaosbits.net, alban.crequy@collabora.co.uk,
	shemminger@vyatta.com, gorcunov@openvz.org, adobriyan@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pauli.nieminen@collabora.co.uk, rweikusat@mssgmbh.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101029.134058.246543591.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 octobre 2010 =C3=A0 13:40 -0700, David Miller a =C3=A9cr=
it :
> From: Jesper Juhl <jj@chaosbits.net>
> Date: Fri, 29 Oct 2010 22:20:12 +0200 (CEST)
>=20
> > Sorry to intrude out of the blue without really understanding the k=
ernel=20
> > side of most of the code in question, but if there's a performance=20
> > regression for applications using poll() shouldn't we address that =
so we=20
> > get back to the prior performance level rather than requireing all=20
> > userspace apps to switch to epoll() ??
>=20
> For such a pathological program like Alban's test case, I say
> absolutely not.

Yes, and with some perf tool help, we probably can find out how to
speedup the thing again, with no API change.

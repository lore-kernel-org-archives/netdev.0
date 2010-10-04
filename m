From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Implement SO_TIMESTAMP and SO_TIMETAMPNS on
 Unix sockets
Date: Mon, 04 Oct 2010 21:20:52 +0200
Message-ID: <1286220052.2381.70.camel@edumazet-laptop>
References: <20101004194734.6a1caf3e@chocolatine.cbg.collabora.co.uk>
	 <1286218109-30771-1-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Poettering <lennart@poettering.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286218109-30771-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 04 octobre 2010 =C3=A0 19:48 +0100, Alban Crequy a =C3=A9crit =
:
> Userspace applications can already request to receive timestamps with=
:
> setsockopt(sockfd, SOL_SOCKET, SO_TIMESTAMP, ...)
>=20
> Although setsockopt() returns zero (success), timestamps are not adde=
d to the
> ancillary data. This patch fixes that on SOCK_DGRAM and SOCK_SEQPACKE=
T Unix
> sockets.
>=20
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Note: tstamp is sampled at the time of skb queueing, _after_ eventual
sleep in sock_alloc_send_skb() or memcpy_fromiovec()

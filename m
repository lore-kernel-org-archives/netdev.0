From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_UNIX: Implement SO_TIMESTAMP and SO_TIMETAMPNS on
 Unix sockets
Date: Tue, 05 Oct 2010 14:55:24 -0700 (PDT)
Message-ID: <20101005.145524.35829931.davem@davemloft.net>
References: <20101004194734.6a1caf3e@chocolatine.cbg.collabora.co.uk>
	<1286218109-30771-1-git-send-email-alban.crequy@collabora.co.uk>
	<1286220052.2381.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alban.crequy@collabora.co.uk, lennart@poettering.net,
	shemminger@vyatta.com, gorcunov@openvz.org, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286220052.2381.70.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Oct 2010 21:20:52 +0200

> Le lundi 04 octobre 2010 =E0 19:48 +0100, Alban Crequy a =E9crit :
>> Userspace applications can already request to receive timestamps wit=
h:
>> setsockopt(sockfd, SOL_SOCKET, SO_TIMESTAMP, ...)
>>=20
>> Although setsockopt() returns zero (success), timestamps are not add=
ed to the
>> ancillary data. This patch fixes that on SOCK_DGRAM and SOCK_SEQPACK=
ET Unix
>> sockets.
>>=20
>> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

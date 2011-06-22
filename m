From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] udp/recvmsg: Clear MSG_TRUNC flag when
 starting over for a new packet
Date: Wed, 22 Jun 2011 07:43:58 +0200
Message-ID: <1308721438.2713.6.camel@edumazet-laptop>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
	 <1308689020-1873-4-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Xufeng Zhang <xufeng.zhang@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57721 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab1FVFoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 01:44:02 -0400
Received: by wwg11 with SMTP id 11so901328wwg.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 22:44:00 -0700 (PDT)
In-Reply-To: <1308689020-1873-4-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 juin 2011 =C3=A0 16:43 -0400, Paul Gortmaker a =C3=A9crit :
> From: Xufeng Zhang <xufeng.zhang@windriver.com>
>=20
> Consider this scenario: When the size of the first received udp packe=
t
> is bigger than the receive buffer, MSG_TRUNC bit is set in msg->msg_f=
lags.
> However, if checksum error happens and this is a blocking socket, it =
will
> goto try_again loop to receive the next packet.  But if the size of t=
he
> next udp packet is smaller than receive buffer, MSG_TRUNC flag should=
 not
> be set, but because MSG_TRUNC bit is not cleared in msg->msg_flags be=
fore
> receive the next packet, MSG_TRUNC is still set, which is wrong.
>=20
> Fix this problem by clearing MSG_TRUNC flag when starting over for a
> new packet.
>=20
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/ipv4/udp.c |    3 +++
>  net/ipv6/udp.c |    3 +++
>  2 files changed, 6 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Mon, 20 Dec 2010 15:37:56 +0100
Message-ID: <1292855876.2800.46.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51695 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472Ab0LTOiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 09:38:01 -0500
Received: by wwa36 with SMTP id 36so3008359wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 06:38:00 -0800 (PST)
In-Reply-To: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 22:35 +0800, Changli Gao a =C3=A9=
crit :
> Pawel reported a panic related to handling shared skbs in ixgbe
> incorrectly. So we need to revert my previous patch to work around
> this bug. Instead of reverting the patch completely, I just revert
> the essential lines, so we can add the previous optimization
> back more easily in future.
>=20
>     commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
>     Author: Changli Gao <xiaosuo@gmail.com>
>     Date:   Sat Oct 16 13:04:08 2010 +0000
>    =20
>         net_sched: remove the unused parameter of qdisc_create_dflt()
>=20
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] l2tp: l2tp_ip - fix possible oops on packet receive
Date: Wed, 25 Jan 2012 14:06:57 +0100
Message-ID: <1327496817.2425.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327495145-6748-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alex <alex@m3x.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64690 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab2AYNHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 08:07:03 -0500
Received: by bkas6 with SMTP id s6so4362735bka.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 05:07:02 -0800 (PST)
In-Reply-To: <1327495145-6748-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 12:39 +0000, James Chapman a =C3=A9c=
rit :
> When a packet is received on an L2TP IP socket (L2TPv3 IP link
> encapsulation), the l2tpip socket's backlog_rcv function calls
> xfrm4_policy_check(). This is not necessary, since it was called
> before the skb was added to the backlog. With CONFIG_NET_NS enabled,
> xfrm4_policy_check() will oops if skb->dev is null, so this trivial
> patch removes the call.
>=20
> This bug has always been present, but only when CONFIG_NET_NS is
> enabled does it cause problems. Most users are probably using UDP
> encapsulation for L2TP, hence the problem has only recently
> surfaced.
>=20
=2E..
> Signed-off-by: James Chapman <jchapman@katalix.com>
>=20
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: alex <alex@m3x.org>
Cc: Ben Hutchings <ben@decadent.org.uk>

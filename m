From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] inet: Add ip_make_skb and ip_send_skb
Date: Tue, 01 Mar 2011 06:31:40 +0100
Message-ID: <1298957500.2676.10.camel@edumazet-laptop>
References: <20110227110614.GA6246@gondor.apana.org.au>
	 <E1Pu1TJ-0005Qw-5I@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33315 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab1CAFbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:31:44 -0500
Received: by wwb22 with SMTP id 22so4014262wwb.1
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:31:43 -0800 (PST)
In-Reply-To: <E1Pu1TJ-0005Qw-5I@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:41 +0800, Herbert Xu a =C3=A9cr=
it :
> inet: Add ip_make_skb and ip_send_skb
>=20
> This patch adds the helper ip_make_skb which is like ip_append_data
> and ip_push_pending_frames all rolled into one, except that it does
> not send the skb produced.  The sending part is carried out by
> ip_send_skb, which the transport protocol can call after it has
> tweaked the skb.
>=20
> It is meant to be called in cases where corking is not used should
> have a one-to-one correspondence to sendmsg.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: md5: RST: getting md5 key from listener
Date: Wed, 01 Feb 2012 10:54:55 +0100
Message-ID: <1328090095.2595.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
	 <1328085348-6771-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39634 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab2BAJy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 04:54:59 -0500
Received: by werb13 with SMTP id b13so794270wer.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 01:54:58 -0800 (PST)
In-Reply-To: <1328085348-6771-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 00:35 -0800, Shawn Lu a =C3=A9c=
rit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When
> connection is gone, md5 key is lost, sending RST
> without md5 hash is deem to ignored by peer. This can
> be a problem since RST help protocal like bgp to fast
> recove from peer crash.
>=20
> In most case, users of tcp md5, such as bgp and ldp,
> have listener on both sides to accept connection from peer.
> md5 keys for peers are saved in listening socket.
>=20
> There are two cases in finding md5 key when connection is
> lost:
> 1.Passive receive RST: The message is send to well known port,
> tcp will associate it with listner. md5 key is gotten from
> listener.
>=20
> 2.Active receive RST (no sock): The message is send to ative
> side, there is no socket associated with the message. In this
> case, finding listener from source port, then find md5 key from
> listener.
>=20
> we are not loosing sercuriy here:
> packet is checked with md5 hash. No RST is generated
> if md5 hash doesn't match or no md5 key can be found.
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
> v4: change title and change log.=20
> regerated after  "tcp: md5: protects md5sig_info with RCU"


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !

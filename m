From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-netlink: Add a new attribute to expose TOS
 values via netlink
Date: Wed, 12 Oct 2011 06:31:09 +0200
Message-ID: <1318393869.3686.26.camel@edumazet-laptop>
References: <20111010145206.6f7e9ee2@nehalam.linuxnetplumber.net>
	 <1318382887-31824-1-git-send-email-muralira@google.com>
	 <1318387734.3686.2.camel@edumazet-laptop>
	 <CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: MuraliRaja Muniraju <muralira@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42594 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab1JLEbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 00:31:15 -0400
In-Reply-To: <CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 octobre 2011 =C3=A0 21:16 -0700, MuraliRaja Muniraju a =C3=A9=
crit :
> Eric,
>      I think it would be useful to expose the values this way.
>      I shall make the changes to add TCLASS for ipv6 in the descripti=
on.
>=20
>      Regarding the TIME_WAIT state, I think it would be better of not
> exposing the values because there would hardly be anything to transmi=
t
> during this time.
>=20

My remark had nothing to do with your patch actually :

We dont store TOS/TCLASS on TIME_WAIT sockets, so you cannot report
value in inet_diag.

But we do send packets on behalf of TIME_WAIT sockets ;)

Think about ACK messages. They probably are sent with a 0 TOS/TCLASS
field... I am not sure its a problem or not.

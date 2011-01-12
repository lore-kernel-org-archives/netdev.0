From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: x_table: speedup compat operations
Date: Wed, 12 Jan 2011 22:03:49 +0100
Message-ID: <1294866229.3335.2.camel@edumazet-laptop>
References: <1292693715.18869.148.camel@edumazet-laptop>
	 <4D2E12B9.6090201@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2E12B9.6090201@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 12 janvier 2011 =C3=A0 21:44 +0100, Pablo Neira Ayuso a =C3=
=A9crit :

> minor glitch: We leak xp->compat_tab if this error condition above is=
 true.
>=20

I dont think so, pointer is stored in xp->compat_tab

xt_compat_flush_offsets() will free it.




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

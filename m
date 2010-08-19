From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netfilter: save the hash of the tuple in the
 original direction for latter use
Date: Thu, 19 Aug 2010 17:46:26 +0200
Message-ID: <1282232786.2549.60.camel@edumazet-laptop>
References: <1282228389-3029-1-git-send-email-xiaosuo@gmail.com>
	 <20100819152149.GA19744@Krystal>
	 <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 23:35 +0800, Changli Gao a =C3=A9crit=
 :

>=20
> In fact, I don't know the reason clearly. This code is derived from
> the older one. Maybe there isn't enough entropy when initializing.
>=20

Yes, we wanted to initialize these random data as late as possible, tha=
t
is when the first entry is added in conntrack hash.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

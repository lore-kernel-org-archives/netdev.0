From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xt_hashlimit: dl_seq_stop() fix
Date: Thu, 25 Mar 2010 11:07:55 +0100
Message-ID: <1269511675.3626.11.camel@edumazet-laptop>
References: <1269463664.2849.9.camel@edumazet-laptop>
	 <4BAB3494.4030402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAB3494.4030402@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 mars 2010 =C3=A0 11:01 +0100, Patrick McHardy a =C3=A9crit =
:
> Eric Dumazet wrote:
> > If dl_seq_start() memory allocation fails, we crash later in
> > dl_seq_stop(), trying to kfree(ERR_PTR(-ENOMEM))
>=20
> Seems pretty counter intuitive to me that ->stop is invoked after
> ->start returned an error.

Yes, I feel your pain :)

At least ->next is not invoked :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Wed, 08 Feb 2012 09:48:41 -0500
Message-ID: <1328712521.2983.1.camel@mojatatu>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
	 <20120207.135841.1753473725075272902.davem@davemloft.net>
	 <20120207201633.GB26533@pandem0nium>
	 <1328692916.2284.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-wireless@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1328692916.2284.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->cb is the right scratch pad to use.
The problem appears to be the wireless stack abusing some of these
fields (prio for one). And we do have marks in place already which
are 32 bit and global.

=20
cheers,
jamal

On Wed, 2012-02-08 at 10:21 +0100, Eric Dumazet wrote:
> Le mardi 07 f=C3=A9vrier 2012 =C3=A0 21:16 +0100, Simon Wunderlich a =
=C3=A9crit :

>=20
> I really dont understand what the conflict might be.
>=20
> As long as skb is in Qdisc layer, Qdisc owns skb->cb[] (a part of it
> actually, see current discussions about IB on netdev)
>=20
> As soon as packet is given to device (mac80211), cb[] can be reused.
>=20
> Or are you saying tc_class also might be needed by mac80211 in the
> future ?
>=20
>=20
>=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

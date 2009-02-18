From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Wed, 18 Feb 2009 16:10:55 +0100
Message-ID: <499C24FF.90302@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499032A4.9090301@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
>=20
> The interface name matching has shown up in profiles forever
> though and we've actually already tried to optimize it IIRC.
>=20
> Eric, I'm trying to keep all the *tables files synchronized,
> could you send me a patch updating the other ones as well
> please?

While doing this, I found arp_tables is still using loop using
byte operations.

Also, I could not find how iniface_mask[], outiface_mask[], iniface[]
and outiface[] were forced to long word alignment ...=20

(in struct ipt_ip, struct ip6t_ip6, struct arpt_arp)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

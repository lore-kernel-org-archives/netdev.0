From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next-2.6] netfilter: add more values to enum ip_conntrack_info
Date: Thu, 02 Jun 2011 13:44:58 +0200
Message-ID: <4DE777BA.5090500@netfilter.org>
References: <1305812667.3028.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1305812667.3028.66.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/05/11 15:44, Eric Dumazet wrote:
> Following error is raised (and other similar ones) :
>=20
> net/ipv4/netfilter/nf_nat_standalone.c: In function =E2=80=98nf_nat_f=
n=E2=80=99:
> net/ipv4/netfilter/nf_nat_standalone.c:119:2: warning: case value =E2=
=80=984=E2=80=99
> not in enumerated type =E2=80=98enum ip_conntrack_info=E2=80=99
>=20
> gcc barfs on adding two enum values and getting a not enumerated
> result :
>=20
> case IP_CT_RELATED+IP_CT_IS_REPLY:
>=20
> Add missing enum values
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>

I have applied this to my net-next-2.6 tree.

http://1984.lsi.us.es/git/?p=3Dnet-next-2.6/.git;a=3Dshortlog;h=3Drefs/=
heads/pablo/nf-next-2.6-updates
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

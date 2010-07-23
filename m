From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 13:49:11 +0200
Message-ID: <4C4981B7.2090101@trash.net>
References: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>	 <1279866541.2482.79.camel@edumazet-laptop>	 <AANLkTikFp9tjtYz5c0GTOfcS1DD8v6fLvBUVVeBVbsns@mail.gmail.com> <1279868302.2482.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36254 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0GWLtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:49:05 -0400
In-Reply-To: <1279868302.2482.113.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2010 08:58, Eric Dumazet wrote:
> Le vendredi 23 juillet 2010 =E0 14:47 +0800, Changli Gao a =E9crit :
>> On Fri, Jul 23, 2010 at 2:29 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>>> Le vendredi 23 juillet 2010 =E0 11:34 +0800, Changli Gao a =E9crit =
:
>>>> iptables: use skb->len for accounting
>>>>
>>>> use skb->len for accounting as xt_quota does.
>>>>
>>>
>>> Why ?
>>>
>>> This is a gratuitous change, unless you have very strong arguments.
>>>
>>> xt_quota is an exception, dont change all others because of it !
>>
>> exception ? Why ?
>=20
> Because it handles all protocols...
>=20
> So skb->len is a shortcut, an approximation if you want.
>=20
> At IPV4 level, ip->tot_len is an exact value.

Actually skb->len is also exact at the IPv4 level. I'm inclined
to apply this patch for consistency with ip6_tables, where using
skb->len fixes jumbo frame accounting.


From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source addresses in ICMPv6 error messages
Date: Thu, 6 Feb 2014 04:38:49 -0800 (PST)
Message-ID: <1391690329.62545.YahooMailNeo@web125506.mail.ne1.yahoo.com>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com> <52F357C3.9060406@6wind.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm46.bullet.mail.ne1.yahoo.com ([98.138.120.53]:22190 "EHLO
	nm46.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758922AbaCEPRi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 10:17:38 -0500
In-Reply-To: <52F357C3.9060406@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>


> Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as so=
urce addresses in ICMPv6 error messages
>=20
> Le 19/01/2014 17:00, Francois-Xavier Le Bail a =E9crit :
>=20
>>  - Uses ipv6_anycast_destination() in icmp6_send().
>>=20
>>  Suggested-by: Bill Fink <billfink@mindspring.com>
>>  Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> This patch causes an Oops on my target.

What is your target ?

> Here is the step to reproduce it:
> modprobe sit
> ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
> ip l s sit1 up
> ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
> ping6 2001:1234::121

I cannot reproduce this in my target (updated net-next x86_64) and
iproute2 from git.
Can you send me your config file ?

> The problem is that ipv6_anycast_destination() uses unconditionally
> skb_dst(skb), which is NULL in this case.
>=20
> Not sure what is the best way to fix this, any suggestions?

I will try to reproduce first and see.

Greetings,
=46rancois-Xavier

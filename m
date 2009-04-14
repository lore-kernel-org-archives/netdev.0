From: Patrick McHardy <kaber@trash.net>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 14:16:37 +0200
Message-ID: <49E47EA5.3060706@trash.net>
References: <20090410191736.21efab8c@mako-desktop> <49E4744D.5090205@trash.net> <49E47C2D.1050508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E47C2D.1050508@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Mariusz Kozlowski wrote:
>>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of
>>> call_rcu()
>> Thanks for the report. Does this patch fix it?
>>
>=20
> Hi Patrick, sorry for the delay, I was in holidays.

No problem, me too :)

> I should have used different fields names (from "next", "first", ...)=
 to catch this
> kind of errors at compile time :(
 >
> Something like :

Thanks Eric. I guess at this point it doesn't really matter anymore
for the upstream kernel, but I'll apply your patch after getting
confirmation from Mariusz to make sure that people maintaining
external patches will notice the change (and won't send me broken
patches :)).
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

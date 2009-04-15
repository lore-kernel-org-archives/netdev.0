From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Wed, 15 Apr 2009 12:42:27 +0200
Message-ID: <49E5BA13.7000501@cosmosbay.com>
References: <20090410191736.21efab8c@mako-desktop> <49E4744D.5090205@trash.net> <49E47C2D.1050508@cosmosbay.com> <49E5B66D.30602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E5B66D.30602@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> I should have used different fields names (from "next", "first", ...=
)
>> to catch this
>> kind of errors at compile time :(
>>
>> Something like :
>>
>> diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
>=20
> Eric, on second thought, could you please resubmit this to Dave?
> It touches too many files outside of netfilter to go through my
> tree.
>=20
>=20

Sure, but its a cleanup (and was an RFC to show my point)
so should wait a litle bit until David opens his -next tree (for 2.6.31=
)

Please just submit your patch for 2.6.30 ?


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

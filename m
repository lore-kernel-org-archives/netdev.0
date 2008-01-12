From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8] [NETFILTER] xt_policy.c: kill some bloat
Date: Sat, 12 Jan 2008 20:03:31 +0100
Message-ID: <47890F03.5080503@trash.net>
References: <12001304703362-git-send-email-ilpo.jarvinen@helsinki.fi>	<12001304703302-git-send-email-ilpo.jarvinen@helsinki.fi>	<12001304703789-git-send-email-ilpo.jarvinen@helsinki.fi> <20080112.032318.201654370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080112.032318.201654370.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 12 Jan 2008 11:34:27 +0200
>=20
> Ilpo, please post netfilter patches to netfilter-devel,
> CC:'ing Patrick McHardy.
>=20
> Patrick, please review, thanks.

This looks fine to me, thanks Ilpo.

>> net/netfilter/xt_policy.c:
>>   policy_mt | -906
>>  1 function changed, 906 bytes removed, diff: -906
>>
>> net/netfilter/xt_policy.c:
>>   match_xfrm_state | +427
>>  1 function changed, 427 bytes added, diff: +427
>>
>> net/netfilter/xt_policy.o:
>>  2 functions changed, 427 bytes added, 906 bytes removed, diff: -479
>>
>> Alternatively, this could be done by combining identical
>> parts of the match_policy_in/out()

That would probably end up rather ugly because they walk
over different structures and have some minor differences.

-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

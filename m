From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Fri, 07 Mar 2008 00:01:41 +0100
Message-ID: <47D077D5.50306@cosmosbay.com>
References: <47CCFC0B.7060801@cosmosbay.com>	<20080303.234649.109971767.davem@davemloft.net>	<47CF2CFA.6000704@cosmosbay.com> <20080305.183539.76566188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:39172
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754422AbYCFXB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:01:56 -0500
In-Reply-To: <20080305.183539.76566188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 06 Mar 2008 00:30:02 +0100
>=20
>> [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst' field=
 and avoid=20
>> casts
>>
>> (Anonymous) unions can help us to avoid ugly casts.
>>
>> A common cast it the (struct rtable *)skb->dst one.
>>
>> Defining an union like  :
>> union {
>>      struct dst_entry *dst;
>>      struct rtable *rtable;
>> };
>> permits to use dkb->rtable in place.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>=20
> Applied with some minor changelog tidy and typo fixups.
>=20
> Please make your changelog entry header lines smaller in
> the future.  People scan them in shortlog output and it's
> less readable if it's wider than standard terminal widths.

Thanks David, I'll try to shorten headers :)


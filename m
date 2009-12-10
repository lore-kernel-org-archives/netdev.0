From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 12:26:38 +0100
Message-ID: <4B20DAEE.1050802@trash.net>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com> <4B207840.7080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chavey@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B207840.7080603@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le 10/12/2009 02:25, chavey@google.com a =E9crit :
>> Fix compiler warning "discards qualifiers from pointer target type".
>> The function prototype defines parameters as pointer to a constant.
>> Such parameters should not have their content modified in the
>> function.
>>
>> Signed-off-by: Laurent Chavey <chavey@google.com>
>=20
> This is not the right fix IMHO.
>=20
> We want an unique timestamp for the whole netfilter matches, because =
several 'time' rules
> could get 'interesting' effects.
>=20
> The 'const' attribute is a debugging aid, and the skb->tstamp 'write-=
once' is a valid exception.

I agree, the timestamps should be consistent among multiple
matches. The cast should also surpress the warning, but some
gcc versions ignore it.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

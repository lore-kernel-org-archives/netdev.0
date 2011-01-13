From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Thu, 13 Jan 2011 17:30:49 +0100
Message-ID: <4D2F28B9.50407@netfilter.org>
References: <4D2E1A74.5080102@netfilter.org>	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>	 <1294918365.3570.56.camel@edumazet-laptop> <4D2EE80B.6010707@netfilter.org>	 <1294925915.3570.87.camel@edumazet-laptop>	 <alpine.LNX.2.01.1101131502240.25211@obet.zrqbmnf.qr> <1294929579.3570.163.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294929579.3570.163.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/01/11 15:39, Eric Dumazet wrote:
> Le jeudi 13 janvier 2011 =C3=A0 15:02 +0100, Jan Engelhardt a =C3=A9c=
rit :
>> On Thursday 2011-01-13 14:38, Eric Dumazet wrote:
>>
>>> Le jeudi 13 janvier 2011 =C3=A0 12:54 +0100, Pablo Neira Ayuso a =C3=
=A9crit :
>>>
>>>> But printing this does not provide any useful information. The fir=
st
>>>> packet that does not belong to the cluster node that has received =
the
>>>> packet, or the first invalid packet, will trigger this.
>>>>
>>>> Moreover, this confuses users since they can do nothing if they re=
ceive
>>>> this message.
>>>>
>>>> Moreover, this target should be supersedes by the cluster match, w=
hich
>>>> has been there for quite some time (it's also more flexible).
>>>
>>> Now you mentioned it, cluster match is not as flexible right now,
>>> its hashing is on source_ip only.
>>
>> I think in that case, xt_cluster should be improved rather
>> than an old module.
>=20
> Amen
>=20
> We should not improve IPv4 support then, I see.
>=20
> My customers use this old module, and upgrading to xt_cluster is not =
an
> option.
>=20
> Should we discuss this forever or fix it ?

hey hey, I'm fine with fixing things. Patch v4 is OK.

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

> In the end, people are forced to add useless iptables rule to DROP
> INVALID packets before entering ipt_CLUSTERIP, after googling or
> eventually asking to experts.
>=20
> Last time this was discussed, this went nowhere :
>=20
> http://www.spinics.net/lists/netfilter/msg48676.html
>=20
> Come on guys, we can do it, dont be afraid.
>=20
> A non rate limited printk() in kernel is forbidden, especially in
> network stack.
>=20
> Then, cluster match can be improved, I am sure you already have a pat=
ch
> for it.

what scenario could benefit from the destination-based hashing?
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

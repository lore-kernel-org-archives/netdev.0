From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Thu, 13 Jan 2011 15:02:38 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101131502240.25211@obet.zrqbmnf.qr>
References: <4D2E1A74.5080102@netfilter.org>  <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>  <1294918365.3570.56.camel@edumazet-laptop> <4D2EE80B.6010707@netfilter.org> <1294925915.3570.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294925915.3570.87.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2011-01-13 14:38, Eric Dumazet wrote:

>Le jeudi 13 janvier 2011 =C3=A0 12:54 +0100, Pablo Neira Ayuso a =C3=A9=
crit :
>
>> But printing this does not provide any useful information. The first
>> packet that does not belong to the cluster node that has received th=
e
>> packet, or the first invalid packet, will trigger this.
>>=20
>> Moreover, this confuses users since they can do nothing if they rece=
ive
>> this message.
>>=20
>> Moreover, this target should be supersedes by the cluster match, whi=
ch
>> has been there for quite some time (it's also more flexible).
>
>Now you mentioned it, cluster match is not as flexible right now,
>its hashing is on source_ip only.

I think in that case, xt_cluster should be improved rather
than an old module.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

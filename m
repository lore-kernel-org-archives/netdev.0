From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 0/5] netfilter: Pass net into ip_route_me_harder
Date: Mon, 28 Sep 2015 09:29:04 +0200
Message-ID: <5608EC40.4060207@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
 <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 25/09/2015 22:01, Eric W. Biederman a =C3=A9crit :
>
> This is the next installment of my work to pass struct net through th=
e
> output path so the code does not need to guess how to figure out whic=
h
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
>
> This round the focus is our getting struct net passed in, instead of
> guess in the netfilter functions that reroute packets
> (ip_route_me_harder, and ip6_route_me_harder).  There is a bit more w=
ork
> on the ipv4 side as the ipv6 code on several of these code paths alre=
ady
> passes in the struct net.
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

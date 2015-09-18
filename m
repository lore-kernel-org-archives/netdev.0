From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 0/14] netfilter: Stop guessing net
Date: Fri, 18 Sep 2015 18:01:28 +0200
Message-ID: <55FC3558.5080601@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/09/2015 17:06, Eric W. Biederman a =C3=A9crit :
>
> This is the next installment of my work to pass struct net through th=
e
> output path so the code does not need to guess how to figure out whic=
h
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
>
> This round the changes focus on using nf_hook_state->net in the
> netfilter functions, and not passing nf_hook_ops to the functions on =
the
> netfilter chains.
>
> Given the way per network namespace operations are implemented caller=
s
> can not rely on addresses or games with container_of.  None of the
> netfilter hooks do but we should remove the temptation.  Plus removin=
g
> the extra parameter and the extra jump to get at values should reduce
> the number of cache line misses.
>
> At a practical matter this is the bulk of the work that other pieces =
of
> code in the netfilter stack will depend on.
I only see the cover letter. Patches are also not visible on the patchw=
ork.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Wed, 19 Dec 2012 06:43:25 -0500
Message-ID: <50D1A85D.1020302@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr> <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com> <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr> <50CF16FE.5040300@mojatatu.com> <alpine.LNX.2.01.1212171401180.25980@nerf07.vanv.qr> <50D06E66.8000600@mojatatu.com> <alpine.LNX.2.01.1212181426590.24597@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212181426590.24597@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-18 08:58 AM, Jan Engelhardt wrote:
>

> Chains can store multiple targets, so no loss.

Nice.

> 1. table
>
> First, I think some targets need to relax their restrictions, such as
> with xt_DSCP.

Saw your other patch to get rid of mangle hardcoding.

> Then, only a handful of extensions remain: CT, <all NATs>,
> TPROXY and REJECT. Would anyone want to call these from act_ipt?
> I doubt it. :)
>

Tempted to say tproxy.

> 2. hooks
>
> Extensions with hook limit: <NAT>, TPROXY, REJECT, CLASSIFY.
> Again, I don't quite see the value of attempting to NAT from act_ipt.
> CLASSIFY {c|sh?}ould be relaxed, unless I am missing something.
>


I could live with that. It would be an improvement over whats there 
today. I would prefer however for this to be an improvement over
act_xt.c i posted as opposed to have even more interfaces for xt.
We've suffered enough already ;-> i.e add your patches on top.

cheers,
jamal


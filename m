From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Thu, 30 Dec 2004 15:09:29 +0100
Message-ID: <20041230140929.GY32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <1104414713.1047.130.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104414713.1047.130.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104414713.1047.130.camel@jzny.localdomain> 2004-12-30 08:51
> In current code you can have CONFIG_NET_CLS_ACT and not use new
> style policer, rather use old one i.e CONFIG_NET_CLS_POLICE. You seem to
> indicate presence of CONFIG_NET_CLS_ACT implies absence of
> NET_CLS_POLICE.

Is this wrong? Current code: (u32)

2004/06/15 hadi       | #ifdef CONFIG_NET_CLS_ACT
2004/06/15 hadi       | 	struct tc_action	*action;
2004/06/15 hadi       | #else
2002/02/05 torvalds   | #ifdef CONFIG_NET_CLS_POLICE
2002/02/05 torvalds   | 	struct tcf_police	*police;
2002/02/05 torvalds   | #endif
2004/06/15 hadi       | #endif

> config NET_CLS_POLICE
>         ...
>         depends on NET_CLS && NET_QOS && NET_ACT_POLICE!=y &&  
> NET_ACT_POLICE!=m

Hmm... doesn't make too much sense for me. What's the advantage of
allowing this mix?

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Sat, 14 Dec 2013 07:22:26 -0500
Message-ID: <52AC4D82.5070505@mojatatu.com>
References: <52AB87EB.6040508@mojatatu.com>	<20131213.182325.2234215963739207753.davem@davemloft.net>	<52ABC975.2070308@mojatatu.com> <20131214.001529.1872893184686335778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:64395 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3LNMWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 07:22:30 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so4321112ieb.4
        for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 04:22:30 -0800 (PST)
In-Reply-To: <20131214.001529.1872893184686335778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/13 00:15, David Miller wrote:

> It is significantly different.
>
> It is an internal kernel interface that was never used.

It is not an internal API, Dave.
It an external kernel module API that has been visible for many years.
It provides "xstats" semantics - which is something an
action user has high potential use for.
It has been used in the past, just not by current in tree users.

> You cannot argue that, because it might have generated a netlink
> attribute had it been implemented, that userland has a dependency upon
> it.

The arguement is: it does expose some very strategically located
attributes. "xstats" sit between basic stats and other attributes
in the netlink layout (just as they do in qdisc and classes).
Yes, no in tree users exist but this feature has been there for
_a few years now_ and is not getting in the way of anything to
deserve chopping down.

Anyways, your call.

cheers,
jamal

From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next 0/6] net_sched: cls_*: couple of fixes
Date: Wed, 3 Dec 2014 13:50:18 +0000
Message-ID: <20141203135018.GA18805@casper.infradead.org>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43317 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbaLCNuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:50:20 -0500
Content-Disposition: inline
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/14 at 06:00pm, Jiri Pirko wrote:
> Jiri Pirko (6):
>   net_sched: cls_basic: remove unnecessary iteration and use passed arg
>   net_sched: cls_bpf: remove unnecessary iteration and use passed arg
>   net_sched: cls_bpf: remove faulty use of list_for_each_entry_rcu
>   net_sched: cls_flow: remove faulty use of list_for_each_entry_rcu
>   net_sched: cls_flow: remove duplicate assignments
>   net_sched: cls_cgroup: remove unnecessary if

Looks sane. RCU is obviously not needed as all cls_api calls
are holding RTNL by now.

Reviewed-by: Thomas Graf <tgraf@suug.ch>

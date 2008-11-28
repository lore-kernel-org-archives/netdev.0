From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/29: Netfilter Update
Date: Fri, 28 Nov 2008 03:03:21 -0800 (PST)
Message-ID: <20081128.030321.122070629.davem@davemloft.net>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 27 Nov 2008 17:15:03 +0100 (MET)

> the following patches contain part 1 of the netfilter updates for 2.6.29.
> The highlights are:
> 
> - netns support for ebtables, ipt_addrtype and some related cleanups from
>   Alexey Dobriyan
> 
> - ctnetlink updates from Pablo: automatic helper module loading, proper
>   event generation for actions performed through ctnetlink, minor cleanups
> 
> - switching of xt_NFLOG to directly use nfnetlink_log as backend instead
>   of the first loaded logging module, which was a constant source of
>   confusion for users. From Eric Leblond. Also from Eric are two patches
>   to support rerouting based on packet marks in nfnetlink_queue.
> 
> - Misc cleanups and minor fixes from myself, Andy Whitcroft, Simon Arlot
>   and Ingo Molnar.
> 
> 
> There's a trivial merge conflict in net/netfilter/nf_conntrack_netlink.c,
> so the patches won't apply directly. Please pull from
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

Pulled and pushed out to net-next-2.6, thanks Patrick!

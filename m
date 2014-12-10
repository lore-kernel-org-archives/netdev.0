From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/2] netfilter: conntrack: route cache for
 forwarded connections
Date: Wed, 10 Dec 2014 15:13:19 +0100
Message-ID: <20141210141319.GA5028@salvia>
References: <1418052964-4632-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	brouer@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52389 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932126AbaLJOK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 09:10:59 -0500
Content-Disposition: inline
In-Reply-To: <1418052964-4632-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2014 at 04:36:02PM +0100, Florian Westphal wrote:
> [ Pablo, in case you deem this too late for -next just let me know
> and I will resend once its open again ]
> 
> This adds an optional forward routing cache extension for netfilter
> connection tracking.
> 
> The memory cost is an additional 32 bytes per conntrack entry
> on x86_64.
> 
> Unlike any other currently implemented connection tracking
> extension the rtcache has no run-time tunables, it is always active.
> 
> Also, unlike other conntrack extensions, it can be built as a module,
> in this case modprobe/rmmod are used to enable/disable the cache.

I expect distributors will provide this a module. I think we should
provide features that can be enable/disable in some way, in this case
it can be modprobe/rmmod.

BTW, did you evaluate Eric's alternative? Any comment on that?

Florian Westphal <fw@strlen.de> wrote:
>> +     if (likely(dst))
>> +             skb_dst_set_noref_force(skb, dst);
>
> Note that Hannes submitted a patch vs. net-next that removes
> skb_dst_set_noref_force().

I refreshed the nf-next tree, this patch is now there.

If the merge window remains open, I'll take the pending patches in
patchwork and send a new batch for David by tomorrow morning.

Let me know, thanks.

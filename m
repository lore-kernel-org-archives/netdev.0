From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Thu, 05 Jan 2017 11:52:49 -0500 (EST)
Message-ID: <20170105.115249.2008034862210327809.davem@davemloft.net>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdAEQwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:52:51 -0500
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  5 Jan 2017 12:19:47 +0100

> The following patchset contains accumulated Netfilter fixes for your
> net tree:
> 
> 1) Ensure quota dump and reset happens iff we can deliver numbers to
>    userspace.
> 
> 2) Silence splat on incorrect use of smp_processor_id() from nft_queue.
> 
> 3) Fix an out-of-bound access reported by KASAN in
>    nf_tables_rule_destroy(), patch from Florian Westphal.
> 
> 4) Fix layer 4 checksum mangling in the nf_tables payload expression
>    with IPv6.
> 
> 5) Fix a race in the CLUSTERIP target from control plane path when two
>    threads run to add a new configuration object. Serialize invocations
>    of clusterip_config_init() using spin_lock. From Xin Long.
> 
> 6) Call br_nf_pre_routing_finish_bridge_finish() once we are done with
>    the br_nf_pre_routing_finish() hook. From Artur Molchanov.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.

And a happy new year to you too!

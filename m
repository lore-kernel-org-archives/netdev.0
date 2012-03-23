From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter updates for net (3.4) tree
Date: Fri, 23 Mar 2012 14:26:18 -0400 (EDT)
Message-ID: <20120323.142618.324554140075237118.davem@davemloft.net>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 23 Mar 2012 10:34:12 +0100

> * One fix for missing symbol in xt_LOG reported by Randy Dunlap.
> 
> * Fix module dependency between cttimeout and nf_conntrack_proto_*
>   friends from me. Now, we make sure that protocol trackers modules
>   cannot be unloaded if there's any cttimeout object refering to
>   them.
> 
> * Fix missing rcu_read_lock section in xt_CT while dereferencing
>   a RCU pointer.
> 
> * Fix the assignation of a custom timeout policy for the generic
>   protocol tracker.
> 
> * Fix possible inconsistencies in the application of the cttimeout
>   policy by permanently attaching it to the conntrack entry. Before
>   this patch, the timeout policy was attached per packet which may
>   result in applying the timeout policy only in one traffic
>   direction.
> 
> You can pull this changes from:
> 
> git://1984.lsi.us.es/net master

Pulled, thanks Pablo.

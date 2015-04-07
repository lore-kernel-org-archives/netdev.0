From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] netfilter: Add nf_hook_state initializer function.
Date: Tue, 07 Apr 2015 11:58:21 -0400 (EDT)
Message-ID: <20150407.115821.441881623894604515.davem@davemloft.net>
References: <20150405.221854.118353659007886815.davem@davemloft.net>
	<1428414081.3965860.250247565.2F639A0C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428414081.3965860.250247565.2F639A0C@webmail.messagingengine.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 07 Apr 2015 15:41:21 +0200

> Minor suggestion:
> 
> I think we can return the structure as a whole:
> 
> static inline struct nf_hook_state nf_hook_state_init(unsigned int hook,
> ...).
> 
> Being static inline it should not make any difference.

If by some insane possibility this does not get inlined, this structure
gets copied to and from the kernel stack on some cpu ABIs in order to
return it.

Never return structures from functions, ever.

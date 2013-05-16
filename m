From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net (3.10-rc1)
Date: Thu, 16 May 2013 14:36:01 -0700 (PDT)
Message-ID: <20130516.143601.736819721136214103.davem@davemloft.net>
References: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 16 May 2013 17:55:17 +0200

> * Fix crash if nf_log_packet is called from conntrack, in that case
>   both interfaces are NULL, from Hans Schillstrom. This bug introduced
>   with the logging netns support in the previous merge window.
> 
> * Fix compilation of nf_log and nf_queue without CONFIG_PROC_FS,
>   from myself. This bug was introduced in the previous merge window
>   with the new netns support for the netfilter logging infrastructure.
> 
> * Fix possible crash in xt_TCPOPTSTRIP due to missing sanity
>   checkings to validate that the TCP header is well-formed, from
>   myself. I can find this bug in 2.6.25, probably it's been there
>   since the beginning. I'll pass this to -stable.
> 
> * Update MAINTAINER file to point to new nf trees at git.kernel.org,
>   remove Harald and use M: instead of P: (now obsolete tag) to
>   keep Jozsef in the list of people.
> 
> Please, consider pulling this. Thanks!
 ..
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks.

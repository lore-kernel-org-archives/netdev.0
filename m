From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Fri, 11 Jan 2013 09:01:36 +0800
Message-ID: <50EF6470.5000303@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com> <20130110164154.GA5457@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130110164154.GA5457@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/01/11 00:41, Pablo Neira Ayuso wrote:
> First off, thanks for looking into this.
> 
> I want to get this fix into 3.8 and -stable but this patch includes a
> rework whose scope is net-next (upcoming 3.9).
> 
> The attached patch aims to fix the issue according to your patch
> description. Once this is in, we can revisit your code refactoring
> proposal.
> 
> Let me know.
> 

Yes,I'm happy this bug being fixed in 3.8.
So what I should do is waiting for below patch being accepted and
then rebase my patchset? It's OK.
Thanks!

> 
> 0001-netfilter-nf_conntrack-fix-BUG_ON-while-removing-nf_.patch
> 
> 
>>From a211bd666fbfe17ae7171a50ad92fedc7b9e19fa Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Thu, 10 Jan 2013 16:12:01 +0100
> Subject: [PATCH] netfilter: nf_conntrack: fix BUG_ON while removing
>  nf_conntrack with netns
> 
> canqun zhang reported that we're hitting BUG_ON in the
> nf_conntrack_destroy path when calling kfree_skb while
> rmmod'ing the nf_conntrack module.
> 
> Currently, the nf_ct_destroy hook is being set to NULL in the
> destroy path of conntrack.init_net. However, this is a problem
> since init_net may be destroyed before any other existing netns
> (we cannot assume any specific ordering while releasing existing
> netns according to what I read in recent emails).
> 
> Thanks to Gao feng for initial patch to address this issue.
> 
> Reported-by: canqun zhang <canqunzhang@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---

Acked-by: Gao feng <gaofeng@cn.fujitsu.com>

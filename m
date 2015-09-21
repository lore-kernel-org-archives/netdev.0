From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net
Date: Sun, 20 Sep 2015 22:32:42 -0700 (PDT)
Message-ID: <20150920.223242.1042651674478554215.davem@davemloft.net>
References: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 18 Sep 2015 11:17:52 +0200

> The following patch contains Netfilter fixes for your net tree, they are:
> 
> 1) nf_log_unregister() should only set to NULL the logger that is being
>    unregistered, instead of everything else. Patch from Florian Westphal.
> 
> 2) Fix a crash when accessing physoutdev from PREROUTING in br_netfilter.
>    This is partially reverting the patch to shrink nf_bridge_info to 32 bytes.
>    Also from Florian.
> 
> 3) Use existing match/target extensions in the internal nft_compat extension
>    lists when the extension is family unspecific (ie. NFPROTO_UNSPEC).
> 
> 4) Wait for rcu grace period before leaving nf_log_unregister().
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.

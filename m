From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter updates for net
Date: Thu, 04 Apr 2013 17:42:13 -0400 (EDT)
Message-ID: <20130404.174213.340982073714686717.davem@davemloft.net>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  4 Apr 2013 14:56:04 +0200

> The following patchset contains netfilter updates for your net tree,
> they are:
> 
> * Fix missing the skb->trace reset in nf_reset, noticed by Gao Feng
>   while using the TRACE target with several net namespaces.
> 
> * Fix prefix translation in IPv6 NPT if non-multiple of 32 prefixes
>   are used, from Matthias Schiffer.
> 
> * Fix invalid nfacct objects with empty name, they are now rejected
>   with -EINVAL, spotted by Michael Zintakis, patch from myself.
> 
> * A couple of fixes for wrong return values in the error path of
>   nfnetlink_queue and nf_conntrack, from Wei Yongjun.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.

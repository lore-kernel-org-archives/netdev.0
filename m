From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 05/18] netfilter: nf_nat: add protoff argument to packet
 mangling functions
Date: Mon, 20 Aug 2012 10:02:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208201000580.6101@frira.zrqbmnf.qr>
References: <1345434006-16549-1-git-send-email-kaber@trash.net> <1345434006-16549-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:45848 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755620Ab2HTICV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 04:02:21 -0400
In-Reply-To: <1345434006-16549-6-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-08-20 05:39, Patrick McHardy wrote:
>index 0bb5a69..4b59a15 100644
>--- a/include/linux/netfilter/nf_conntrack_amanda.h
>+++ b/include/linux/netfilter/nf_conntrack_amanda.h
>@@ -4,6 +4,7 @@
> 
> extern unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
> 					  enum ip_conntrack_info ctinfo,
>+					  unsigned int protoff,
> 					  unsigned int matchoff,
> 					  unsigned int matchlen,
> 					  struct nf_conntrack_expect *exp);

What about using a structure to collect all the accumulating parameters,
like we do for xtables match functions?

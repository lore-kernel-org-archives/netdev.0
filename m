From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/18] netfilter updates for net-next (try 2)
Date: Mon, 29 Apr 2013 15:17:25 -0400 (EDT)
Message-ID: <20130429.151725.110767875347050549.davem@davemloft.net>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758574Ab3D2TR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:17:27 -0400
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 29 Apr 2013 20:22:06 +0200

> This is a second pull request resolving the compilation issue in
> net/sched/em_ipset.
> 
> The following patchset contains relevant updates for the Netfilter
> tree, they are:
> 
> * Enhancements for ipset: Add the counter extension for sets, this
>   information can be used from the iptables set match, to change
>   the matching behaviour. Jozsef required to add the extension
>   infrastructure and moved the existing timeout support upon it.
>   This also includes a change in net/sched/em_ipset to adapt it to
>   the new extension structure.
> 
> * Enhancements for performance boosting in nfnetlink_queue: Add new
>   configuration flags that allows user-space to receive big packets (GRO)
>   and to disable checksumming calculation. This were proposed by Eric
>   Dumazet during the Netfilter Workshop 2013 in Copenhagen. Florian
>   Westphal was kind enough to find the time to materialize the proposal.
> 
> * A sparse fix from Simon, he noticed it in the SCTP NAT helper, the fix
>   required a change in the interface of sctp_end_cksum.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Pulled, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] netfilter updates for net-next
Date: Mon, 24 Sep 2012 15:41:46 -0400 (EDT)
Message-ID: <20120924.154146.1340089668693733600.davem@davemloft.net>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757869Ab2IXTlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:41:51 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Mon, 24 Sep 2012 21:19:12 +0200

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi David,
> 
> This patchset contains updates for your net-next tree, they are:
> 
> * Mostly fixes for the recently pushed IPv6 NAT support:
> 
> - Fix crash while removing nf_nat modules from Patrick McHardy.
> - Fix unbalanced rcu_read_unlock from Ulrich Weber.
> - Merge NETMAP and REDIRECT into one single xt_target module, from
>   Jan Engelhardt.
> - Fix Kconfig for IPv6 NAT, which allows inconsistent configurations,
>   from myself.
> 
> * Updates for ipset, all of the from Jozsef Kadlecsik:
> 
> - Add the new "nomatch" option to obtain reverse set matching.
> - Support for /0 CIDR in hash:net,iface set type.
> - One non-critical fix for a rare crash due to pass really
>   wrong configuration parameters.
> - Coding style cleanups.
> - Sparse fixes.
> - Add set revision supported via modinfo.i
> 
> * One extension for the xt_time match, to support matching during
>   the transition between two days with one single rule, from
>   Florian Westphal.
> 
> * Fix maximum packet length supported by nfnetlink_queue and add
>   NFQA_CAP_LEN attribute, from myself.
> 
> You can notice that this batch contains a couple of fixes that may
> go to 3.6-rc but I don't consider them critical to push them:
> 
> * The ipset fix for the /0 cidr case, which is triggered with one
>   inconsistent command line invocation of ipset.
> 
> * The nfnetlink_queue maximum packet length supported since it requires
>   the new NFQA_CAP_LEN attribute to provide a full workaround for the
>   described problem.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks Pablo.

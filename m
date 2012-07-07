From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/18] netfilter updates for net-next (upcoming 3.6),
 batch 5
Date: Sat, 07 Jul 2012 16:23:25 -0700 (PDT)
Message-ID: <20120707.162325.1303254492632445927.davem@davemloft.net>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab2GGXXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 19:23:32 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Fri,  6 Jul 2012 13:16:50 +0200

> The following patchset includes Netfilter updates for your net-next tree,
> more specifically:
> 
> * Updates to clean-up the sysctl namespace support for nf_conntrack
>   from Gao Feng and a couple of patches from myself. After these, we
>   can prepare follow-up patches to reduce ifdef pollution regarding
>   sysctl support in nf_conntrack_proto_*.c files.
> 
> * Check for invalid flags set via NFQA_CFG_FLAGS in nfnetlink_queue
>   from Krishna Kumar.
> 
> * Allow to obtain conntrack statistics via ctnetlink from mysqlf. This
>   supersedes /proc/net/stat/nf_conntrack and
>   /proc/sys/net/netfilter/nf_conntrack_count.
> 
> * Don't crash if we send a message to nfnetlink and there is not defined
>   callback to handle such message. Instead, nfnetlink returns -EINVAL from
>   Tomasz Bursztyka. This one does not really fix anything now, that's
>   why I'm passing this via net-next.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master
> 

Pulled, thanks Pablo.

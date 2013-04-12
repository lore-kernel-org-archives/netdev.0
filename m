From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter fixes for net
Date: Fri, 12 Apr 2013 14:28:17 -0400 (EDT)
Message-ID: <20130412.142817.1030983883455796787.davem@davemloft.net>
References: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859Ab3DLS2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:28:19 -0400
In-Reply-To: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 12 Apr 2013 12:13:15 +0200

> The following patchset contains late netfilter fixes for your net
> tree, they are:
> 
> * Don't drop segmented TCP packets in the SIP helper, we've got reports
>   from users that this was breaking communications when the SIP phone
>   messages are larger than the MTU, from Patrick McHardy.
> 
> * Fix refcount leak in the ipset list set, from Jozsef Kadlecsik.
> 
> * On hash set resizing, the nomatch flag was lost, thus entirely inverting
>   the logic of the set matching, from Jozsef Kadlecsik.
> 
> * Fix crash on NAT modules removal. Timer expiration may race with the
>   module cleanup exit path while deleting conntracks, from Florian
>   Westphal.

Pulled, thanks Pablo.

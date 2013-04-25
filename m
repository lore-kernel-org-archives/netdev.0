From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: fix address check in rtnl_fdb_del
Date: Thu, 25 Apr 2013 04:17:51 -0400 (EDT)
Message-ID: <20130425.041751.1238975265643296947.davem@davemloft.net>
References: <1366751123-10143-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab3DYIRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:17:53 -0400
In-Reply-To: <1366751123-10143-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 23 Apr 2013 17:05:23 -0400

> Commit 6681712d67eef14c4ce793561c3231659153a320
> 	vxlan: generalize forwarding tables
> 
> relaxed the address checks in rtnl_fdb_del() to use is_zero_ether_addr().
> This allows users to add multicast addresses using the fdb API.  However,
> the check in rtnl_fdb_del() still uses a more strict
> is_valid_ether_addr() which rejects multicast addresses.  Thus it
> is possible to add an fdb that can not be later removed.
> Relax the check in rtnl_fdb_del() as well.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.

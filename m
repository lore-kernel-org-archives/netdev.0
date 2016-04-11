From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Mon, 11 Apr 2016 15:18:53 -0400 (EDT)
Message-ID: <20160411.151853.799647031209557799.davem@davemloft.net>
References: <1460038860-25670-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbcDKTSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 15:18:55 -0400
In-Reply-To: <1460038860-25670-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  7 Apr 2016 07:21:00 -0700

> Multipath route lookups should consider knowledge about next hops and not
> select a hop that is known to be failed.
> 
> Example:
 ...
> The failed path can be avoided by considering known neighbor information
> when selecting next hops. If the neighbor lookup fails we have no
> knowledge about the nexthop, so give it a shot. If there is an entry
> then only select the nexthop if the state is sane. This is similar to
> what fib_detect_death does.
> 
> To maintain backward compatibility use of the neighbor information is
> based on a new sysctl, fib_multipath_use_neigh.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.

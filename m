From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] Kill rt->rt_dst usage in options processing.
Date: Fri, 13 May 2011 17:51:29 -0400 (EDT)
Message-ID: <20110513.175129.780266990646522789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab1EMVvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:51:36 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4DLpUXn021411
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:51:34 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, this kills the rest of the rt->rt_dst uses in IP options
handling.

The main obstacle was ip_rt_get_source().  Solved simply by passing
the SKB in so that we can fetch the keys from there if needed.

After that the rest became trivial.

All real uses of rt->rt_dst are now entirely limited to route.c

Signed-off-by: David S. Miller <davem@davemloft.net>


From: David Miller <davem@davemloft.net>
Subject: Re: net: Utility function to get affinity_hint by policy
Date: Thu, 06 Mar 2014 17:34:49 -0500 (EST)
Message-ID: <20140306.173449.1703210385202256497.davem@davemloft.net>
References: <1394126332-11110-2-git-send-email-amirv@mellanox.com>
	<20140306.153835.2248996436618700806.davem@davemloft.net>
	<20140306222441.GA17512@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, prarit@redhat.com, gvaradar@cisco.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaCFWev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:34:51 -0500
In-Reply-To: <20140306222441.GA17512@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Fri, 7 Mar 2014 00:24:43 +0200

> All these could be changed dynamically, and since there is no
> protection on this block of code, it is possible that local + non-local
> at point of time t1 will exceed num_online_cpus() at t2.
> Since this is very rare and the fix for that is very complicated, I
> decided not set affinity hint in this scenario, and only return an
> error code.

Ok, fair enough.

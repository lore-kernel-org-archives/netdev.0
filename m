From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/net/ethernet/ibm/ehea/ehea_main.c: add
 alias entry for portN properties
Date: Fri, 13 Sep 2013 19:58:57 -0400 (EDT)
Message-ID: <20130913.195857.1842211951469893139.davem@davemloft.net>
References: <20130913215201.6501131C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ohering@suse.com,
	cascardo@linux.vnet.ibm.com, jeffm@suse.com, jslaby@suse.cz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3IMX67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 19:58:59 -0400
In-Reply-To: <20130913215201.6501131C1BF@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 13 Sep 2013 14:52:01 -0700

> From: Olaf Hering <ohering@suse.com>
> Subject: drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties
> 
> Use separate table for alias entries in the ehea module, otherwise the
> probe() function will operate on the separate ports instead of the
> lhea-"root" entry of the device-tree
> 
> Addresses https://bugzilla.novell.com/show_bug.cgi?id=435215
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> Signed-off-by: Olaf Hering <ohering@suse.com>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This can definitely have consequences and in particular potentially cause
a device to not get probed properly.

Therefore I want an ehea driver maintainer to review and ACK this before
I apply it.

Thanks.

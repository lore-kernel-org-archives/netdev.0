From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:17:53 -0700 (PDT)
Message-ID: <20150827.221753.1685094662698420131.davem@davemloft.net>
References: <20150827.220538.2154843333132928646.davem@davemloft.net>
	<55DFEC92.8050700@cumulusnetworks.com>
	<55DFEDA1.2070903@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbH1FRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:17:54 -0400
In-Reply-To: <55DFEDA1.2070903@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 22:12:01 -0700

> perhaps an example helps:
> 
> swapper 0 [000] 406.447548: fib:fib_table_lookup: table 255 oif 0 iif
> 0 src 0.0.0.0 dst 2.1.1.2 tos 0 scope 0 flags 0
> 
> If src and dst are u32's then they print as either 0x%x or %d which is
> not intuitive. I added support to perf for the following printk
> formats with 3d199b5be53:
 ...

The following had better work:

	__u32 addr;
	printk("%pI4\n", &addr);

We do it everywhere in the networking code.

I don't know why you think it is required to use an array.

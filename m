From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fix randconfig errros in bnx2i/bnx2fc caused
 by IPV6
Date: Mon, 15 Sep 2014 17:45:42 -0400 (EDT)
Message-ID: <20140915.174542.1800056695683269477.davem@davemloft.net>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, mchan@broadcom.com,
	eddie.wai@broadcom.com, rdunlap@infradead.org, jim.epost@gmail.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127AbaIOVpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:45:45 -0400
In-Reply-To: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Mon, 15 Sep 2014 13:45:19 -0700

> Just like CNIC bnx2i/bnx2fc also have their tristate dependent on IPV6, however
> using the same solution as CNIC can cause recursive dependecies during make.
> 
> Based on suggestions by Randy Dunlap, SCSI_NETLINK now depends on NET instead
>  of selecting NET. Second patch fixes the actual randconfig error.
> 
> Entire thread can be followed here : https://lkml.org/lkml/2014/9/9/500
> -Anish
> 
> Fixes: c99d667e8527 ("cnic : Cleanup CONFIG_IPV6 & VLAN check")

Series applied, thank you.

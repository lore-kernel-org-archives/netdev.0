From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Gratuitous ARP gets dropped when first slave
 added
Date: Wed, 12 Aug 2015 14:38:29 -0700 (PDT)
Message-ID: <20150812.143829.2181531591935198645.davem@davemloft.net>
References: <20150811145723.GA18921@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbbHLVia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:38:30 -0400
In-Reply-To: <20150811145723.GA18921@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Tue, 11 Aug 2015 07:57:23 -0700

> When the first slave is added (such as during bootup) the first
> gratuitous ARP gets dropped. We don't see this drop during a failover.
> The packet gets dropped in qdisc (noop_enqueue).
> 
> The fix is to delay the sending of gratuitous ARPs till the bond dev's
> carrier is present.
> 
> It can also be worked around by setting num_grat_arp to more than 1.
> 
> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Applied, thanks.

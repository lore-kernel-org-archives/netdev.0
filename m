From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc1-mm2
Date: Fri, 14 Jul 2006 00:33:34 -0700 (PDT)
Message-ID: <20060714.003334.57160916.davem@davemloft.net>
References: <20060713224800.6cbdbf5d.akpm@osdl.org>
	<44B73FEE.6040908@reub.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22709
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964801AbWGNHda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 03:33:30 -0400
To: reuben-lkml@reub.net
In-Reply-To: <44B73FEE.6040908@reub.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Reuben Farrelly <reuben-lkml@reub.net>
Date: Fri, 14 Jul 2006 18:55:42 +1200

> Ugh.  This on bootup..
> 
> Starting HAL daemon: BUG: warning at net/core/dev.c:1171/skb_checksum_help()

It's perfectly normal, and it's there to remind us that
we need to deal with an incremental checksumming issue
wrt. ip_nat_fn for GSO segments at some point.

You can safely ignore it for now.

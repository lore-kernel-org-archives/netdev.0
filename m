From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] expose simplified skb_checksum_recalc
Date: Fri, 12 May 2006 12:52:04 -0700 (PDT)
Message-ID: <20060512.125204.51641088.davem@davemloft.net>
References: <20060510152244.44fb3db7@localhost.localdomain>
	<200605111924.33125.netdev@axxeo.de>
	<20060511112843.6532bddd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, ioe-lkml@rameria.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65253
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751363AbWELTwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 15:52:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060511112843.6532bddd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 11 May 2006 11:28:43 -0700

> Many users of skb_checksum_help() are just using it to recalculate
> outbound checksum, so why not expose the interface in a more useful
> way. Suggested by Ingo Oeser.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Since you will be adding the first users of skb_checksum_recalc(),
feel free to push this change in via your net driver tree whenever
you feel it is appropriate Stephen.

Thanks.

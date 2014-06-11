From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/4] bnx2x: Fix link for KR with swapped polarity
 lane
Date: Wed, 11 Jun 2014 12:27:17 -0700 (PDT)
Message-ID: <20140611.122717.1580710630812722628.davem@davemloft.net>
References: <1402493248-5427-2-git-send-email-yuval.mintz@qlogic.com>
	<53985B45.9020604@cogentembedded.com>
	<B5657A6538887040AD3A81F1008BEC63AE83CA@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	Yaniv.Rosner@qlogic.com, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbaFKT1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 15:27:18 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63AE83CA@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 11 Jun 2014 18:40:35 +0000

>>> +                             MDIO_WC_REG_RX0_PCI_CTRL + (0x10 * lane), &val);
> 
>>    () around * not needed. You could also replace it by (lane << 4).
> 
> Hi,
> 
> bnx2x_link.c is full of format inconsistencies, as well as many cases of
> unnecessary parenthesis.
> It might be reasonable to send a semantic script to `net-next' in order
> to fix all those issues, but I'm not sure we should re-spin this series
> only because of such `common' inconsistencies.
> 
> Dave - whichever you prefer; If you want me to re-spin it, I will.

Please respin.

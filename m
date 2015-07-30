From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pktgen: Remove unused 'allocated_skbs' field
Date: Wed, 29 Jul 2015 23:01:06 -0700 (PDT)
Message-ID: <20150729.230106.1714595320812695413.davem@davemloft.net>
References: <1438163236-12593-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bogdan.hamciuc@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbG3GBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:01:07 -0400
In-Reply-To: <1438163236-12593-1-git-send-email-bogdan.hamciuc@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Date: Wed, 29 Jul 2015 12:47:16 +0300

> Field pktgen_dev.allocated_skbs had been written to, but never read
> from. The number of allocated skbs can be deduced anyway, from the total
> number of sent packets and the 'clone_skb' param.
> 
> Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>

Also applied to net-next, thanks.

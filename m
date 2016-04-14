From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ethernet/jme.c: Deinline
 jme_reset_mac_processor, save 2816 bytes
Date: Wed, 13 Apr 2016 22:57:29 -0400 (EDT)
Message-ID: <20160413.225729.470470760283188607.davem@davemloft.net>
References: <1460140787-12610-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbcDNC5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:57:31 -0400
In-Reply-To: <1460140787-12610-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Fri,  8 Apr 2016 20:39:47 +0200

> This function compiles to 895 bytes of machine code.
> 
> Clearly, this isn't a time-critical function.
> For one, it has a number of udelay(1) calls.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

No x.c file should be using inline anyways, applied to net-next,
thanks a lot!

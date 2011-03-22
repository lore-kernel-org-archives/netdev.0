From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: smsc95xx: don't use stack for async writes to the
 device
Date: Tue, 22 Mar 2011 01:02:34 -0700 (PDT)
Message-ID: <20110322.010234.98886588.davem@davemloft.net>
References: <1300456438-13286-1-git-send-email-marc.zyngier@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: marc.zyngier@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755123Ab1CVIBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:01:55 -0400
In-Reply-To: <1300456438-13286-1-git-send-email-marc.zyngier@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Zyngier <marc.zyngier@arm.com>
Date: Fri, 18 Mar 2011 13:53:58 +0000

> The set_multicast operation performs asynchronous writes to the
> device, with some addresses pointing to the stack. Bad things may
> happen, and this is trapped CONFIG_DMA_API_DEBUG:
...
> Move the two offenders to the private structure which is kmalloc-ed,
> and thus safe.
> 
> Signed-off-by: Marc Zyngier <marc.zyngier@arm.com>
> Cc: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks.

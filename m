From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on
 interrupt context.
Date: Mon, 05 Oct 2009 05:37:59 -0700 (PDT)
Message-ID: <20091005.053759.74765905.davem@davemloft.net>
References: <Pine.GSO.4.10.10910050757300.9377-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753598AbZJEMiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:38:05 -0400
In-Reply-To: <Pine.GSO.4.10.10910050757300.9377-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 07:58:42 -0400 (EDT)

> - Added macros that check if the thread is in interrupt context or not to
>   acquire or release locks
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

There is nothing at all wrong with using irqsave/irqrestore spin lock
calls when you're already in an interrupt.

I don't see any reason for this change.

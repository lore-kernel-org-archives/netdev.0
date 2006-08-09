From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Tue, 08 Aug 2006 22:51:20 -0700
Message-ID: <44D977D8.5070306@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193447.1396.59301.sendpatchset@lappy> <44D9191E.7080203@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:49225 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1030492AbWHIFvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:51:38 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44D9191E.7080203@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Peter Zijlstra wrote:
>> Update the driver to make use of the netdev_alloc_skb() API and the
>> NETIF_F_MEMALLOC feature.
> 
> NETIF_F_MEMALLOC does not exist in the upstream tree...  nor should it, 
> IMO.

Elaborate please.  Do you think that all drivers should be updated to
fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
If so, I trust you will help audit for it?

> netdev_alloc_skb() is in the tree, and that's fine.

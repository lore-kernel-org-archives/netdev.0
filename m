From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: skb_defer_rx_timestamp should check for
 phydev before setting up classify
Date: Thu, 09 Jul 2015 14:17:40 -0700 (PDT)
Message-ID: <20150709.141740.665818246418073474.davem@davemloft.net>
References: <20150709180252.1686.56670.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbbGIVRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:17:40 -0400
In-Reply-To: <20150709180252.1686.56670.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 09 Jul 2015 11:02:52 -0700

> This change makes it so that the call skb_defer_rx_timestamp will first
> check for a phydev before going in and manipulating the skb->data and
> skb->len values.  By doing this we can avoid unnecessary work on network
> devices that don't support phydev.  As a result we reduce the total
> instruction count needed to process this on most devices.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

This looks fine, applied, thanks Alex.

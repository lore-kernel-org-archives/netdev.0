From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] e1000e: save skb counts in TX to
 avoid cache misses
Date: Thu, 06 May 2010 00:19:34 -0700 (PDT)
Message-ID: <20100506.001934.212692803.davem@davemloft.net>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, therbert@google.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753568Ab0EFHT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:19:27 -0400
In-Reply-To: <20100506000221.8042.64794.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 17:02:27 -0700

> From: Tom Herbert <therbert@google.com>
> 
> In e1000_tx_map, precompute number of segements and bytecounts which
> are derived from fields in skb; these are stored in buffer_info.  When
> cleaning tx in e1000_clean_tx_irq use the values in the associated
> buffer_info for statistics counting, this eliminates cache misses
> on skb fields.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

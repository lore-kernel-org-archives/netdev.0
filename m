From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] e1000e: increase rx fifo size to 36K
 on 82574 and 82583
Date: Thu, 06 May 2010 00:25:42 -0700 (PDT)
Message-ID: <20100506.002542.52183792.davem@davemloft.net>
References: <20100505082537.5956.86868.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755361Ab0EFHZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:25:35 -0400
In-Reply-To: <20100505082537.5956.86868.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 01:25:42 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change increases the RX fifo size to 36K for standard frames and
> decreases the TX fifo size to 4K.  The reason for this change is that on
> slower systems the RX is much more likely to backfill and need space than
> the TX is.  As long as the TX fifo is twice the size of the MTU we should
> have more than enough TX fifo.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

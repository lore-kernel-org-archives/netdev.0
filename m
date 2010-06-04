From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: only check pfc bits in hang logic if
 pfc is enabled
Date: Fri, 04 Jun 2010 15:58:02 -0700 (PDT)
Message-ID: <20100604.155802.246514067.davem@davemloft.net>
References: <20100604030314.16356.79492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757429Ab0FDW5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:57:52 -0400
In-Reply-To: <20100604030314.16356.79492.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Jun 2010 20:03:45 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Only check pfc bits in hang logic if PFC is enabled.  Previously,
> if DCB was enabled but PFC was disabled the incorrect pause
> bits would be checked.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

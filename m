From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Mon, 19 Jul 2010 20:24:17 -0700 (PDT)
Message-ID: <20100719.202417.218061462.davem@davemloft.net>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	<20100719235925.14112.65890.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758162Ab0GTDYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:24:02 -0400
In-Reply-To: <20100719235925.14112.65890.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jul 2010 16:59:27 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change removes UDP from the supported protocols for RSS hashing.  The
> reason for removing this protocol is because IP fragmentation was causing a
> network flow to be broken into two streams, one for fragmented, and one for
> non-fragmented and this in turn was causing out-of-order issues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 18/20] ixgbe: combine Rx into into
 ixgbe_configure_rx
Date: Thu, 19 Aug 2010 16:47:21 -0700 (PDT)
Message-ID: <20100819.164721.35017789.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819234004.10335.44104.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754016Ab0HSXrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:47:04 -0400
In-Reply-To: <20100819234004.10335.44104.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:40:06 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The Rx init is currently split over ixgbe_configure, ixgbe_configure_rx,
> and ixgbe_up_complete.  Instead of leaving it split over 3 function it is
> easier to consolidate them all into ixgbe_configure_rx.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

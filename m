From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/4] igb/e1000e: update PSSR_MDIX value to
 reflect correct bit
Date: Tue, 26 May 2009 20:36:31 -0700 (PDT)
Message-ID: <20090526.203631.231703292.davem@davemloft.net>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
	<20090526235105.28231.39406.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755763AbZE0Dgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:36:31 -0400
In-Reply-To: <20090526235105.28231.39406.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 16:51:05 -0700

> The phy port status register has the MDI-X status bit on bit 11, not bit 3
> as is currently setup in the define.  This patch corrects that so the
> correct bit is checked on igp PHY types.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

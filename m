From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 03/20] ixgbe: move setting of GSO size for
 82598 into ixgbe_configure_dcb
Date: Thu, 19 Aug 2010 16:46:03 -0700 (PDT)
Message-ID: <20100819.164603.112614958.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233402.10335.66985.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60412
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753796Ab0HSXpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:45:47 -0400
In-Reply-To: <20100819233402.10335.66985.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:34:04 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> We are unnecessarily modifying the GSO size for all HW when we don't need
> to.  The code can be simplified by moving the check for DCB and the
> adjustment of the GSO size for 82598 into ixgbe_configure_dcb.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

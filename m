From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 12/20] ixgbe: remove redundant
 configuration of vmolr, rename generic variable
Date: Thu, 19 Aug 2010 16:46:51 -0700 (PDT)
Message-ID: <20100819.164651.102573647.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233745.10335.58155.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753981Ab0HSXqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:34 -0400
In-Reply-To: <20100819233745.10335.58155.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:37:48 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The vmolr is configured already in ixgbe_set_rx_mode for the PF so there is
> no need to set it again in ixgbe_configure_rx.
> 
> Instead of using the variable name reg, it is easier to just rename it to
> gcr_ext to reflect the register contents that the variable holds.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: update set_rx_mode to fix issues
 w/ macvlan
Date: Tue, 15 Jun 2010 14:24:14 -0700 (PDT)
Message-ID: <20100615.142414.116384803.davem@davemloft.net>
References: <20100615192432.3011.29215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	xma@us.ibm.com, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754208Ab0FOVYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:03 -0400
In-Reply-To: <20100615192432.3011.29215.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 15 Jun 2010 12:25:48 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects issues where macvlan was not correctly triggering
> promiscuous mode on ixgbe due to the filters not being correctly set.  It
> also corrects the fact that VF rar filters were being overwritten when the
> PF was reset.
> 
> CC: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

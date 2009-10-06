From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 10/15] igb: change how we handle alternate
 mac addresses
Date: Tue, 06 Oct 2009 15:21:37 -0700 (PDT)
Message-ID: <20091006.152137.141192646.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163424.32487.97223.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933796AbZJFWVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:42 -0400
In-Reply-To: <20091005163424.32487.97223.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:34:25 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch allows us to treat the alternate mac address as though it is the
> physical address on the adapter.  This is accomplished by letting the
> alt_mac_address function to only fail on an NVM error.  If no errors occur
> and the alternate mac address is not present then RAR0 is read as the
> default mac address.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

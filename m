From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbevf: Fix panic when loading driver
Date: Tue, 17 Jul 2012 02:57:12 -0700 (PDT)
Message-ID: <20120717.025712.301877208665987955.davem@davemloft.net>
References: <1342518288-13522-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab2GQJ5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 05:57:15 -0400
In-Reply-To: <1342518288-13522-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 17 Jul 2012 02:44:48 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch addresses a kernel panic seen when setting up the interface.
> Specifically we see a NULL pointer dereference on the Tx descriptor cleanup
> path when enabling interrupts.  This change corrects that so it cannot
> occur.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2 1/2] ixgbe: Fix
 tx_restart_queue/non_eop_desc statistics counters
Date: Tue, 15 Dec 2009 21:13:54 -0800 (PST)
Message-ID: <20091215.211354.189718802.davem@davemloft.net>
References: <20091215215636.25793.78144.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752035AbZLPFNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 00:13:53 -0500
In-Reply-To: <20091215215636.25793.78144.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 15 Dec 2009 13:56:59 -0800

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Fix the restart_queue and non_eop_desc counters from being
> double-counted.  They are cumulative in each ring, so we don't want to
> add them to the cumulative result in the adapter's master counter.
> Otherwise, the stats will be inaccurate
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2 2/2] ixgbe: Fix 82598 premature copper PHY
 link indicatation
Date: Tue, 15 Dec 2009 21:14:00 -0800 (PST)
Message-ID: <20091215.211400.112615561.davem@davemloft.net>
References: <20091215215636.25793.78144.stgit@localhost.localdomain>
	<20091215215720.25793.52500.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752153AbZLPFN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 00:13:59 -0500
In-Reply-To: <20091215215720.25793.52500.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 15 Dec 2009 13:57:20 -0800

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Modified patch with Dave's comments to replace mdelay with proper msleep.
> Fix 82598 copper link issue, where the phy prematurely indicates link
> before it is ready to process packets. The new function looks for phy
> link and indicates that, when it is available. If phy is not ready
> within few seconds of MAC indicating link, the function will return
> failure which translates to link down indication.
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

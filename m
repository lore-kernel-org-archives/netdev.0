From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] Provide common means for device address
 sync
Date: Mon, 02 Jun 2014 10:41:47 -0700 (PDT)
Message-ID: <20140602.104147.434358215603709678.davem@davemloft.net>
References: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, neepatel@cisco.com, _govind@gmx.com,
	benve@cisco.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbaFBRls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:41:48 -0400
In-Reply-To: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 28 May 2014 18:44:41 -0700

> The following series implements a means for synchronizing both unicast and
> multicast addresses on a device interface.  The code is based on the original
> implementation of dev_uc_sync that was available for syncing a VLAN to the
> lower dev.
> 
> The original reason for coming up for this patch is a driver that is still in
> the early stages of development.  The nearest driver I could find that
> appeared to have the same limitations as the driver I was working on was the
> Cisco enic driver.  For this reason I chose it as the first driver to make use
> of this interface publicly.
> 
> However, I do not have a Cisco enic interface so I have only been able to
> compile test any changes made to the driver.  I tried to keep this change as
> simple as possible to avoid any issues.  Any help with testing would be
> greatly appreciated.

Series applied, thanks Alexander.

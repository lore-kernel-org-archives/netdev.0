From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Wed, 29 May 2013 00:34:30 -0700 (PDT)
Message-ID: <20130529.003430.1619161536594986905.davem@davemloft.net>
References: <CDCA3AA1.1E8D4%matthew.vick@intel.com>
	<02874ECE860811409154E81DA85FBB58564F1C88@ORSMSX104.amr.corp.intel.com>
	<20130529072445.GA4868@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, matthew.vick@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935084Ab3E2Heb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 03:34:31 -0400
In-Reply-To: <20130529072445.GA4868@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 29 May 2013 09:24:45 +0200

> Also, using ethtool or sysfs is not really attractive for embedded
> designs (let's not forget the poor embedded guys). I think we need to
> have a way to specify the pin functions at (or before) kernel boot
> time.  Barring DT and kconfig, using a module parameter is the only
> way to accomplish this.

No module parameters.

The embedded guys can run an ethtool command early in boot
right after the driver loads.

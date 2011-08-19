From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fix IBM EMAC driver after rename.
Date: Thu, 18 Aug 2011 21:33:57 -0700 (PDT)
Message-ID: <20110818.213357.918078950828913782.davem@davemloft.net>
References: <20110819035413.GH19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: tony@bakeyournoodle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab1HSEgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 00:36:03 -0400
In-Reply-To: <20110819035413.GH19739@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Breeds <tony@bakeyournoodle.com>
Date: Fri, 19 Aug 2011 13:54:13 +1000

> In commit 9aa3283595451ca093500ff0977b106e1f465586 (ehea/ibm*: Move the
> IBM drivers) the IBM_NEW_EMAC* were renames to IBM_EMAC*
> 
> The conversion was incomplete so that even if the driver was added to
> the .config it wasn't built, but there were no errors).  In this commit
> we also update the various defconfigs that use EMAC to use the new
> Kconfig symbol, and explicitly add the NET_VENDOR_IBM guard.
> 
> We do not explicitly select the Kconfig dependencies, as this would force
> EMAC on.  Doing it in the defconfig allows more flexibility.
> 
> Tested on a canyondlands board.
> 
> Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

Applied, thanks.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Bonding fixes for 2.6.33.y
Date: Tue, 29 Nov 2011 02:19:59 +0000
Message-ID: <1322533200.26733.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Neil Horman <nhorman@tuxdriver.com>, <netdev@vger.kernel.org>
To: <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:60524 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752010Ab1K2CUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 21:20:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These have been applied to 2.6.32.y but are missing from 2.6.33.y:

commit ab12811c89e88f2e66746790b1fe4469ccb7bdd9
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Fri Sep 10 11:43:20 2010 +0000

    bonding: correctly process non-linear skbs

commit b30532515f0a62bfe17207ab00883dd262497006
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Thu Jan 20 09:02:31 2011 +0000

    bonding: Ensure that we unshare skbs prior to calling pskb_may_pull

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

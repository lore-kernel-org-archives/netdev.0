From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 14:56:32 -0800
Message-ID: <20111116225632.GA3556@mcarlson.broadcom.com>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
 <20111116.173618.213297028503733251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3661 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154Ab1KPWzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 17:55:37 -0500
In-Reply-To: <20111116.173618.213297028503733251.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 02:36:18PM -0800, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Tue, 15 Nov 2011 14:00:53 -0800
> 
> > Translating between ethtool advertisement settings and MII
> > advertisements are common operations for ethernet drivers.  This patch
> > adds a set of helper functions that implements the conversion.  The
> > patch then modifies a couple of the drivers to use the new functions.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Doesn't build:
> 
> In file included from drivers/net/ethernet/3com/3c59x.c:82:0:
> include/linux/mii.h: In function ?ethtool_adv_to_mii_100bt?:
> include/linux/mii.h:254:15: error: ?ADVERTISED_10baseT_Half? undeclared (first use in this function)
> include/linux/mii.h:254:15: note: each undeclared identifier is reported only once for each function it appears in
> include/linux/mii.h:256:15: error: ?ADVERTISED_10baseT_Full? undeclared (first use in this function)
> include/linux/mii.h:258:15: error: ?ADVERTISED_100baseT_Half? undeclared (first use in this function)
> include/linux/mii.h:260:15: error: ?ADVERTISED_100baseT_Full? undeclared (first use in this function)
> include/linux/mii.h:262:15: error: ?ADVERTISED_Pause? undeclared (first use in this function)
> include/linux/mii.h:264:15: error: ?ADVERTISED_Asym_Pause? undeclared (first use in this function)

I forgot to add '#include <linux\ethtool.h>' to mii.h.  I guess for the
drivers I enabled, ethtool.h was already included.  New patch on its
way.

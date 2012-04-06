From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 0/6] Documentation fixes
Date: Fri, 6 Apr 2012 01:37:47 +0100
Message-ID: <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28017 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752951Ab2DFAhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes update Documentation/networking/driver.txt and
Documentation/networking/netdevices.txt to reflect the last 5 or so
years of API changes (though no new features are documented).

They also remove documentation of a wrinkle in ethtool_ops that I
recently fixed.

These could safely be applied to either net or net-next; they can't
break anything but another 3 months of dust isn't going to make much
difference.

Ben.

Ben Hutchings (6):
  ethtool: Remove exception to the requirement of holding RTNL lock
  doc, net: Remove obsolete reference to dev->poll
  doc, net: Update documentation of synchronisation for TX multiqueue
  doc, net: Update netdev operation names
  doc, net: Remove instruction to set net_device::trans_start
  doc, net: Update ndo_start_xmit return type and values

 Documentation/networking/driver.txt     |   31 +++++++++++++++----------------
 Documentation/networking/netdevices.txt |   25 ++++++++++++-------------
 include/linux/ethtool.h                 |    3 +--
 3 files changed, 28 insertions(+), 31 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

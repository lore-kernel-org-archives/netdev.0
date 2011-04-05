From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/7] bridge enhancements for net-next
Date: Mon, 04 Apr 2011 17:03:26 -0700
Message-ID: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42822 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab1DEAJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add more netlink support for bridge.
It is possible to do basic configuration bridge with just netlink.
Later enhancements will add statistics and parameters.

The intention is to switch to pure netlink in future and support
RSTP and deprecate the old ioctl, sysfs and STP code.


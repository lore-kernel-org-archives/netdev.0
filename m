From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/8] Convert even more drivers to set_phys_id
Date: Mon, 04 Apr 2011 14:06:34 -0700
Message-ID: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43870 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab1DDWSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts most drivers to the new set_phys_id ethtool ops.
The three remaining drivers do things that are harder to convert since
they all use a mailbox model. These should all compile, but not
tested.



From: <zyjzyj2000@gmail.com>
Subject: [PATCH V4] ixgbe: synchronize the link_speed and link_up of a slave interface
Date: Wed, 30 Dec 2015 17:16:32 +0800
Message-ID: <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
References: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:52797 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359AbbL3JQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 04:16:35 -0500
In-Reply-To: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

According to Rustad, Mark D, maybe it is related with copper phy. To make fiber phy more
robust, synchronize both the link_up and link_speed of a slave interface in ixgbe driver.

Best Regards!
Zhu Yanjun

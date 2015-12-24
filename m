From: <zyjzyj2000@gmail.com>
Subject: [V2 PATCH 1/1] ixgbe: force to synchronize reporting "link on" and
Date: Thu, 24 Dec 2015 11:12:31 +0800
Message-ID: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
References: <1450868046.3316.11.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:58538 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbbLXDM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:12:28 -0500
In-Reply-To: <1450868046.3316.11.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Jeff

Thanks for your reply.

Changes:
Since there is a time span between link_up and link_speed to X540 NIC, it is not appropriate to continue in the function ixgbe_watchdog_link_is_up if only link_up is ready.

Best Regards!
Zhu Yanjun

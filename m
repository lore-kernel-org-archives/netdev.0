From: <zyjzyj2000@gmail.com>
Subject: [PATCH V6] ixgbe: synchronize link_up and link_speed of a slave
Date: Thu, 31 Dec 2015 15:11:38 +0800
Message-ID: <1451545899-16584-1-git-send-email-zyjzyj2000@gmail.com>
References: <1451540268.3348.108.camel@intel.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:46861 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbLaHLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 02:11:38 -0500
In-Reply-To: <1451540268.3348.108.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

Thanks for the reply from Jeff.

V2: Based on feedback from Jeff Kirsher, it is not appropriate to continue
    in the function ixgbe_watchdog_link_is_up without link_speed since this will
    make some virtual NICs not work well.

V3: Based on feedback from Emil Tantilov, the time span between link_up 
    and link_speed is not important when the X540 NIC acts as an independent 
    interface. 

V4: According to Rustad, Mark D, maybe it is related with copper phy. To make
    fiber phy more robust, synchronize both the link_up and link_speed of a slave
    interface in ixgbe driver.

V5: Based on feedback from Rustad, Mark D, simplify code comment and if statement 
    to only test for IFF_SLAVE flag and unknown link speed.

V6: Based on feedback from Jeff Kirsher, the patch format is adjusted 
    and change log of this patch are added.

Best Regards!
Zhu Yanjun

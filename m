From: <zyjzyj2000@gmail.com>
Subject: [PATCH V3] ixgbe: force to synchronize link_up and speed as a slave
Date: Tue, 29 Dec 2015 10:32:04 +0800
Message-ID: <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
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
Received: from mail.windriver.com ([147.11.1.11]:50205 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbbL2Cc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 21:32:29 -0500
In-Reply-To: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

During the discussion with Emil, I think the time span between link_up 
and link_speed is not important when the X540 NIC acts as an independent 
interface. As such, a new patch is made to restrict synchronization 
between link_up and link_speed.

Any reply is appreciated.

Zhu Yanjun

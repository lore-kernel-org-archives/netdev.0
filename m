From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: 2.6.19-rc6-mm2: Network device naming starts at 1 instead of 0
Date: Tue, 05 Dec 2006 14:07:39 -0800
Message-ID: <4575EDAB.6060305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27424 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760214AbWLEWHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 17:07:53 -0500
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[resend]

Quick note: I loaded up 2.6.19-rc6-mm2 on a platform here and noticed that the onboard
e1000 NIC was enumerated to eth1 instead of eth0. on 2.6.18.5 and any other kernel I
used before, it was properly named eth0 after startup. eth0 itself is completely missing
(-ENODEV).

I'll try to see if I can point out the culprit, but perhaps this rings a bell to anyone.

Cheers,

Auke

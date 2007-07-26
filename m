From: Ayyappan.Veeraiyan@intel.com
Subject: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters -
	Take #3
Date: Thu, 26 Jul 2007 13:08:32 -0700
Message-ID: <20070726200105.27129.18979.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ayyappan.veeraiyan@intel.com, arjan@linux.intel.com,
	akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	hch@infradead.org, shemminger@linux-foundation.org,
	nhorman@tuxdriver.com, inaky@linux.intel.com, mb@bu3sch.de,
	john.ronciak@intel.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12261 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338AbXGZUIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 16:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Intel(R) 82598 based PCI Express 10GbE 
adapters.

Please find the full driver as a patch to latest linus-2.6 tree here:
    git-pull git://lost.foo-projects.org/~aveerani/git/linux-2.6 ixgbe

Changes from the last submission...
1. Non-NAPI support is removed. 
2. Ethtool support for wol indication and nway_reset ops. 
3. Buf fix for issue - interface down/up after changing MAC address loses
	connectivity.
4. Some general cleanups.

thanks,
Ayyappan

From: Ayyappan.Veeraiyan@intel.com
Subject: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters -
	Take #2
Date: Tue, 10 Jul 2007 10:45:20 -0700
Message-ID: <20070710174504.9615.10053.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ayyappan.veeraiyan@intel.com, arjan@linux.intel.com,
	akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	hch@infradead.org, shemminger@linux-foundation.org,
	nhorman@tuxdriver.com, inaky@linux.intel.com, mb@bu3sch.de
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62720 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449AbXGJRpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 13:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Intel(R) 82598 based PCI Express 10GbE 
adapters.

Please find the full driver as a patch to latest linus-2.6 tree here:
    git-pull git://lost.foo-projects.org/~aveerani/git/linux-2.6 ixgbe

Changes from the last submission...
1. Suspend, resume support is added
2. PCI error recovery support 
3. Bit fields usage is removed and replaced with #defines.
4. typedef boolean_t is replaced with bool.
5. Ethtool functionality for eeprom and regiters dump and adapter
	identification.
6. RxDescriptor, TxDescriptors and XsumRx parameters are removed
	from the module param list. They can be handled via ethtool.
7. NAPI mode uses sigle Rx queue and so fake netdev usage is removed.
8. Non-NAPI mode is added.
9. LLTX is not used and tx_lock usage in xmit_frame is cleand up.
10. Performance and bug fixes.

thanks,
Ayyappan

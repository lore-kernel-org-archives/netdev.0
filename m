From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/6] Network flow classifier
Date: Thu, 21 Apr 2011 13:40:14 -0700
Message-ID: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19694 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150Ab1DUUkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are meant to add support for the network flow classifier
interface built into the ethtool_rxnfc.

Once this has been accepted I plan to submit the kernel portion to Jeff
Kirsher as it is almost all ixgbe code changes with the exception of the
removal of support for ethtool_get_rx_ntuple from the kernel.

Thanks,

Alex

---

Alexander Duyck (5):
      Update documentation for -u/-U operations
      Add support for __be64 and bitops to ethtool
      ethtool: remove strings based approach for displaying n-tuple
      Add support for NFC flow classifier extensions
      Add support for ESP as a separate protocol from AH

Santwona Behera (1):
      v4 Add RX packet classification interface


 Makefile.am      |    3 
 ethtool-bitops.h |   25 +
 ethtool-copy.h   |   39 +-
 ethtool-util.h   |   44 ++
 ethtool.8.in     |  193 +++++----
 ethtool.c        |  449 +++++++++++-----------
 rxclass.c        | 1106 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1519 insertions(+), 340 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

-- 

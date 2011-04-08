From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 0/2] Start of work to cleanup ntuple filters
Date: Fri, 08 Apr 2011 15:07:16 -0700
Message-ID: <20110408220410.25468.49130.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46733 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040Ab1DHWHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:07:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the start of my work to cleanup ntuple filters and the
way they are implemented in ixgbe.  These first two patches lay the groundwork
for moving ixgbe over to using the network flow classifier interface instead
of the ntuple interface.

This will eventually allow for ixgbe to be able to maintain its own rule list,
add support for removal of filters, and will correct the multiple display
issues seen with ntuple filters.

---

Alexander Duyck (2):
      ethtool: add ntuple flow specifier data to network flow classifier
      ethtool: prevent null pointer dereference with NTUPLE set but no set_rx_ntuple


 include/linux/ethtool.h |   52 +++++++++++++++++++++++++++++------------------
 net/core/ethtool.c      |    3 +++
 net/socket.c            |   14 ++++++-------
 3 files changed, 42 insertions(+), 27 deletions(-)

-- 

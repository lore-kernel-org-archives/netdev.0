From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] bonding: add even more netlink attributes
Date: Tue, 17 Dec 2013 21:30:02 -0800
Message-ID: <20131218052755.13529.61835.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45774 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3LRFaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements five more bonding netlink attributes:


	num_grat_arp|num_unsol_na
	all_slaves_active
	min_links
	lp_interval
	packets_per_slave

Tested with modified iproute2 to verify attributes can be set at bond creation
time or set later.  Verified sysfs interface to attributes continues to work.

I have one more set after this one for all of the 802.3ad attributes.  Whew.

---

Scott Feldman (5):
      bonding: add num_grat_arp attribute netlink support
      bonding: add all_slaves_active attribute netlink support
      bonding: add min_links attribute netlink support
      bonding: add lp_interval attribute netlink support
      bonding: add packets_per_slave attribute netlink support


 drivers/net/bonding/bond_netlink.c |   78 ++++++++++++++++++++++++
 drivers/net/bonding/bond_options.c |   80 +++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  116 +++++++++++++++++-------------------
 drivers/net/bonding/bonding.h      |    7 ++
 include/uapi/linux/if_link.h       |    5 ++
 5 files changed, 225 insertions(+), 61 deletions(-)

-- 
Signature

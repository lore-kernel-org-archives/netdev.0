From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] bonding: add some more netlink attributes
Date: Sun, 15 Dec 2013 16:41:44 -0800
Message-ID: <20131216003741.13453.71746.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44633 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LPAls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:41:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements five more bonding netlink attributes:

	primary
	primary_reselect
	fail_over_mac
	xmit_hash_policy
	resend_igmp

Tested with modified iproute2 to verify attributes can be set at bond creation
time or set later.  Verified sysfs interface to attributes continues to work.

---

Scott Feldman (5):
      bonding: add primary attribute netlink support
      bonding: add primary_select attribute netlink support
      bonding: add fail_over_mac attribute netlink support
      bonding: add xmit_hash_policy attribute netlink support
      bonding: add resend_igmp attribute netlink support


 drivers/net/bonding/bond_netlink.c |   76 ++++++++++++++++++++
 drivers/net/bonding/bond_options.c |  109 ++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  139 +++++++++++-------------------------
 drivers/net/bonding/bonding.h      |    7 ++
 include/uapi/linux/if_link.h       |    5 +
 5 files changed, 240 insertions(+), 96 deletions(-)

-- 
Signature

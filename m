From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/8] bonding: add more netlink attributes
Date: Thu, 07 Nov 2013 01:42:46 -0800
Message-ID: <20131107093823.15846.31745.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37357 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3KGJtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:49:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following Jiri Pirko's lead, add more bonding netlink attributes.  Sending
matching iproute2 patch separately.  sysfs access to attributes is
retained.

There are more bonding attributes to add to netlink; I'll save those for a
follow-on patch set.

---

Scott Feldman (8):
      bonding: add miimon netlink support
      bonding: add updelay netlink support
      bonding: add downdelay netlink support
      bonding: add use_carrier netlink support
      bonding: add arp_interval netlink support
      bonding: add arp_ip_target netlink support
      bonding: add arp_validate netlink support
      bonding: add arp_all_targets netlink support


 drivers/net/bonding/bond_netlink.c |  145 +++++++++++++++-
 drivers/net/bonding/bond_options.c |  297 ++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  335 ++++++++----------------------------
 drivers/net/bonding/bonding.h      |   10 +
 include/uapi/linux/if_link.h       |    8 +
 5 files changed, 529 insertions(+), 266 deletions(-)

-- 

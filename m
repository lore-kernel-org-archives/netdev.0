From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v1 net-next 0/5] add netlink support for new lacp bonding parameters
Date: Fri,  1 May 2015 10:24:33 -0700
Message-ID: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33740 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbEARYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:24:54 -0400
Received: by pdbnk13 with SMTP id nk13so97732535pdb.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:24:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmit of Mahesh's last 3 bonding patches from this series
(http://marc.info/?l=linux-netdev&m=142432864626179&w=2) with one
additional kernel patch which adds the netlink bits. I have noted any
modifications I did to the original patches just above my signoff line.
Patch 5 is the iproute2 support for these bonding options. All patches
were coded against the net-next branch of their respective projects.

Kernel series:

Andy Gospodarek (1):
  bonding: add netlink support for sys prio, actor sys mac, and port
    key

Mahesh Bandewar (3):
  bonding: Allow userspace to set actors' system_priority in AD system
  bonding: Allow userspace to set actors' macaddr in an AD-system.
  bonding: Implement user key part of port_key in an AD system.

 Documentation/networking/bonding.txt |   84 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.c       |   26 +++++++----
 drivers/net/bonding/bond_main.c      |   25 ++++++++++
 drivers/net/bonding/bond_netlink.c   |   50 ++++++++++++++++++++
 drivers/net/bonding/bond_options.c   |   73 +++++++++++++++++++++++++++++
 drivers/net/bonding/bond_procfs.c    |    8 ++++
 drivers/net/bonding/bond_sysfs.c     |   69 ++++++++++++++++++++++++++++
 include/net/bond_options.h           |    3 ++
 include/net/bonding.h                |    3 ++
 include/uapi/linux/if_link.h         |    3 ++
 10 files changed, 335 insertions(+), 9 deletions(-)

iproute2 series:

Jonathan Toppins (1):
      iplink_bond: add support for ad_actor and port_key options

 ip/iplink_bond.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

-- 
1.7.10.4

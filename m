From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 0/5] RSS improvements + new speeds
Date: Sun, 25 Jan 2015 15:51:18 +0200
Message-ID: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55328 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753868AbbAYNvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:51:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

This patchset contains some features and small bug fixes.
A patch by Eyal Perry to enable setting RSS hash function, kernel support was
added in commit 892311f ("ethtool: Support for configurable RSS hash
function").
Eyal Grossman added some missing advertised speeds and fixed some issues in
this area of code.

Patches were tested and applied on top of commit 4614098 ("Release version 3.16.")

Thanks,
Amir

Eyal Grossman (3):
  ethtool-copy.h: sync with net
  ethtool: Add missing Advertised speeds
  ethtool: Return bad status when send_ioctl fails

Eyal Perry (2):
  ethtool: Prettify RX flow hash indirection table print
  ethtool: Support for configurable RSS hash function

 ethtool-copy.h |  67 +++++++++++++++++++++++++++----
 ethtool.8.in   |   7 ++++
 ethtool.c      | 122 ++++++++++++++++++++++++++++++++++++++++-----------------
 3 files changed, 152 insertions(+), 44 deletions(-)

-- 
1.9.3

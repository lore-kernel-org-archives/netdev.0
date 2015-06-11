From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH ethtool V3 0/2] Add copybreak support
Date: Thu, 11 Jun 2015 15:15:26 +0300
Message-ID: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, _govind@gmx.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49592 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752577AbbFKMQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 08:16:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

This series add support for setting/getting driver's tx/rx_copybreak value.

Copybreak is handled through a new ethtool tunable interface.

The kernel support will be avilable from kernel 4.2, commit "net/ethtool: Add
current supported tunable options".

The series was originally sent by Govindarajulu Varadarajan, I fixed the
comments and resend the series.

Thanks,
Hadar

Changes form V2:
- Change "-B/-b" to generic tunable option.
- Remove tunable names from user space, defined tunable strings names in the
  kernel.
- Remove the third patch - "ethtool-copy.h: Sync with net-next 3.17.0-rc7"

Govindarajulu Varadarajan (2):
  ethtool: Add copybreak support
  ethtool.8.in: Add man page for tunable copybreak

 ethtool-copy.h |   1 +
 ethtool.8.in   |  20 +++++
 ethtool.c      | 227 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 248 insertions(+)

-- 
1.8.3.1

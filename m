From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V8 PATCH 0/2] Add virtual port netlink support
Date: Fri, 14 May 2010 18:04:23 -0700
Message-ID: <20100515010415.21260.35219.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:16094 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab0EOBEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 21:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Add symmetrical set/get layout per Patrick McHardy suggestions]

The following series adds virtual port netlink support and adds an
implementation to Cisco's enic netdev driver:

	1/2: Adds virtual netlink RTM_SETLINK/RTM_GETLINK support, and
	     adds matching netdev ops net_{set|get}_vf_port.

	2/2: Adds enic support for net_{set|get}_vf_port for enic
	     dynamic devices.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>

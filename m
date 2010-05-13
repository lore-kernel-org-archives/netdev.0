From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V6 PATCH 0/2] Add virtual port netlink support
Date: Thu, 13 May 2010 13:17:14 -0700
Message-ID: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:39820 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759164Ab0EMURQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 16:17:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds virtual port netlink support and adds an
implementation to Cisco's enic netdev driver:

	1/2: Adds virtual netlink RTM_SETLINK/RTM_GETLINK support, and
	     adds matching netdev ops net_{set|get}_vf_port.

	2/2: Adds enic support for net_{set|get}_vf_port for enic
	     dynamic devices.

Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>

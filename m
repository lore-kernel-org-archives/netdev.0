From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V7 PATCH 0/2] Add virtual port netlink support
Date: Thu, 13 May 2010 18:35:20 -0700
Message-ID: <20100514013144.1816.31191.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:17406 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab0ENBfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resend with fixes for these items from Patrick McHardy: 1) add #define to
ignore VF num, 2) whitespace cleanup of IFLA_VF_PORT policy list, 3) clean
up err handling for ndo_get_vf_port call]

The following series adds virtual port netlink support and adds an
implementation to Cisco's enic netdev driver:

	1/2: Adds virtual netlink RTM_SETLINK/RTM_GETLINK support, and
	     adds matching netdev ops net_{set|get}_vf_port.

	2/2: Adds enic support for net_{set|get}_vf_port for enic
	     dynamic devices.

Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>

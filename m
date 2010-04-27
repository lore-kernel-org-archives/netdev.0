From: Patrick@trash.net, McHardy@trash.net, kaber@trash.net
Subject: [PATCH 0/4] net: ipmr netlink interface for route dumping
Date: Tue, 27 Apr 2010 15:26:22 +0200
Message-ID: <1272374785-3858-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab0D0N02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 09:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add support to ipmr to dump routes of all tables over
netlink. The /proc interface contains an unterminated list of oifs
at the end of a line, therefore it can't be extended to print the
routing table number without breaking backwards compatibility.

These patches fully decouple rtnetlink families from real address
families and add a new family RTNL_FAMILY_IPMR for ipmr as well as
a RTM_GETROUTE handler.

The first patch additionally marks the fib_rules_ops templates as
const __net_initdata. This is not directly related to the netlink
interface, but was already queued in my tree.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

Thanks!

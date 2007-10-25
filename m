From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv4 0/3 (+3)] Interface group patches
Date: Thu, 25 Oct 2007 17:03:06 +0200
Message-ID: <11933245923082-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:51746 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758152AbXJYPDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 11:03:19 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 31C78C1304
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 17:03:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the 4th version of our interface group patches. The only difference
from the previous one is in the first patch (single notification and atomic
changes in rtnetlink) plus in iptables code: parameter in-ifgroup changed to
ifgroup-in (and ifgroup-out).

I had to add IFLA_NET_NS_PID in the iproute2 patches as in kernel v2.6.24-rc1.

Usage as before:
 ip link set eth0 group 4
 iptables -A INPUT -m ifgroup --ifgroup-in 4/0xf -j ACCEPT
 iptables -A FORWARD -m ifgroup --ifgroup-in 4 --ifgroup-out 5 -j DROP

Patches:
 [1/3] rtnetlink: setlink changes atomic with single notification
 [2/3] Interface group: core (netlink) part
 [3/3] Netfilter Interface group match
 [iptables] Interface group match
 [iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
 [iproute 2/2] Interface group as new ip link option

Please apply,
Attila

From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 0/2] Interface groups
Date: Tue, 16 Oct 2007 10:01:40 +0200
Message-ID: <ifgroup.20071015.1192520046.panther__47102.0093573772$1192521786$gmane$org@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:56583 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbXJPIBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 04:01:47 -0400
Message-Id: <ifgroup.20071015.1192520046.panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Different network interfaces can be grouped using the same group ID. With this
patch fewer netfilter rules are necessary but it may also be used by routing.

The interface group (ifgroup) member of the net_device can be modified via
netlink (with iproute2) and it is used in the new 'ifgroup' netfilter match. 

ip link set eth0 group 4
iptables -A INPUT -m ifgroup --if-group 4 -j ACCEPT

--
Laszlo Attila Toth

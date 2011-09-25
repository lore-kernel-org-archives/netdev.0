From: Marc Haber <mh+netdev@zugschlus.de>
Subject: cannot assign IPv6 address to dummy interface
Date: Sun, 25 Sep 2011 12:13:00 +0200
Message-ID: <20110925101300.GA3316@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33827 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab1IYKNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 06:13:02 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7lhk-0000sE-PQ
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 12:13:00 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is a locally compiled vanilla 3.0.4 kernel on Debian sid.

$ uname -a
Linux swivel 3.0.4-zgws1 #2 SMP PREEMPT Sat Sep 24 12:34:50 UTC 2011 x86_64 GNU/Linux
$ ip addr show dev dummy0
7: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br0 state UNKNOWN
    link/ether 06:b8:41:e5:aa:aa brd ff:ff:ff:ff:ff:ff
$ sudo ip addr add dev dummy0 192.168.18.254/24 brd +
$ sudo ip addr add dev dummy0 2a01:238:4071:321f::100/64
RTNETLINK answers: Permission denied
$ sudo ip addr add dev eth0 2a01:238:4071:321f::100/64
$ ip addr show dev eth0
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether f0:de:f1:79:90:1c brd ff:ff:ff:ff:ff:ff
    inet6 2a01:238:4071:321f::100/64 scope global tentative
       valid_lft forever preferred_lft forever
$ ip addr show dev dummy0
7: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br0 state UNKNOWN
    link/ether 06:b8:41:e5:aa:aa brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.254/24 brd 192.168.18.255 scope global dummy0
$

Why is root not allowed to assign an IPv6 address to a dummy interface?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

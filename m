From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Weird DHCP related problems with net-next
Date: Tue, 09 Jun 2015 11:54:50 -0700
Message-ID: <5577367A.50901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36179 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932242AbbFISz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 14:55:57 -0400
Received: by qgep100 with SMTP id p100so8724322qge.3
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 11:55:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am observing a strange problem on net-next (not observed with net,
bisection in progress) where the initial DHCP configuration using
busybox's udhcpc is able to configure the local interface address and
DNS serer, but not the default gateway. Restarting udhcpc a second time
does not exhibit this problem.

This is a system using SYSTEMPORT and the DSA SF2 switch but I could
also observe it on systems using the BCMGENET and Asix USB 2.0 network
drivers (all in tree).

Are there any netlink/packet/rhashtable changes in net-next, but not in
net that could explain that? Note that this is a system with very low
entropy on boot? Making the DHCP client more verbose or stracing it did
not expose the issue as frequently, so this might be some sort of race
condition.

Any hints appreciated!
-- 
Florian

From: Mahesh Kelkar <maheshkelkar@gmail.com>
Subject: Question: Is multipath routing supported for IPv6
Date: Mon, 9 Aug 2010 14:48:28 -0400
Message-ID: <AANLkTimNDk=Rb3GDx+5Vr9mSU9OoPHZkG5M--oG+Rejr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57233 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab0HISsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 14:48:30 -0400
Received: by wwj40 with SMTP id 40so11928625wwj.1
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 11:48:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried configuring multipath Ipv6 route using "iproute2" tool and it failed:

> ip route add 143:2:3:4::/64 nexthop dev eth0
RTNETLINK answers: No such device

Same Command works for Ipv4. I looked into the source code and I don't
see support for RTA_MULTIPATH in IPV6 codebase.

I wonder if netlink configuration part is missing, or entire support
for multipath is missing. Is there any historical reason for not
supporting it?

Thanks
Mahesh

From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Subject: Linux MPLS traceroute failure
Date: Sun, 13 Aug 2017 01:42:43 +0300
Message-ID: <206091502577763@web5g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward101p.mail.yandex.net ([77.88.28.101]:57818 "EHLO
        forward101p.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752023AbdHLWue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 18:50:34 -0400
Received: from mxback5g.mail.yandex.net (mxback5g.mail.yandex.net [IPv6:2a02:6b8:0:1472:2741:0:8b7:166])
        by forward101p.mail.yandex.net (Yandex) with ESMTP id 053036A82530
        for <netdev@vger.kernel.org>; Sun, 13 Aug 2017 01:42:44 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing MPLS from Linux kernel 4.12. The trace route is duplicete pe-p hop. This is not visible MPLS label on traceroute.

root@ne-vlezay80:~# traceroute -e 10.10.10.4
traceroute to 10.10.10.4 (10.10.10.4), 30 hops max, 60 byte packets
 1  10.5.5.1 (10.5.5.1)  0.028 ms  0.005 ms  0.006 ms
 2  10.4.4.2 (10.4.4.2)  0.021 ms  0.007 ms  0.012 ms
 3  10.4.4.2 (10.4.4.2)  0.008 ms  0.008 ms  0.007 ms
 4  10.10.10.4 (10.10.10.4)  0.015 ms  0.009 ms  0.008 ms
root@ne-vlezay80:~# 

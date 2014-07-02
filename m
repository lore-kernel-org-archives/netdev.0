From: Venkataratnam Naidu <ratnameee@gmail.com>
Subject: Ping between two end hosts failing with ipsec tunnel mode with
 3.10.28 linux kernel
Date: Wed, 2 Jul 2014 15:37:55 +0530
Message-ID: <CANgMM_CDxhXxDy=zkixPMuRwQ8aMFB_H7VgyBNtKLD5koZuT6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:54333 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbaGBKH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 06:07:57 -0400
Received: by mail-la0-f52.google.com with SMTP id ty20so6689765lab.25
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 03:07:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This is my first post to netdev, if this is not the right forum to ask
questions/report issues. please divert me to the correct mail list.

I had configured ipsec tunnel between two routers(R1: 5.0.0.1 & R2:
5.0.0.2), when ipsec is enabled Tunnel is getting established but not
able to ping between two end hosts with 3.10.28 linux kernel. I didn't
see this behaviour with 2.6.28 linux kernel. Please let me know any
one observing the same behaviour on 3.10.28 kernel.
Without ipsec  ping is success from H1 1.0.0.50 to H2 2.0.0.50. If i
enable ipsec(tunnel is established  between two routers) and ping from
H1 1.0.0.50 to H2: 2.0.0.50 is failing.
Linux kernel on both routers are same.
root@OpenWrt:/# uname -a
Linux OpenWrt 3.10.28 #4 SMP PREEMPT Fri Jun 27 11:17:52 IST 2014 mips GNU/Linux
root@OpenWrt:/#
Below are the ip configs for two routers.
R1: 1.0.0.20 & 5.0.0.1     H1: 1.0.0.50 which is connected to R1
Routes on R1
root@OpenWrt:/# route
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
1.0.0.0         *               255.0.0.0       U     0      0        0 eth0
2.0.0.0         5.0.0.2         255.0.0.0       UG    0      0        0 eth1
5.0.0.0         *               255.0.0.0       U     0      0        0 eth1
root@OpenWrt:/#
R2: 5.0.0.2 & 2.0.0.20      H2: 2.0.0.50 which is connected to R2
Routes on R2
root@OpenWrt:/# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
1.0.0.0         5.0.0.1         255.0.0.0       UG    0      0        0 eth1
2.0.0.0         *               255.0.0.0       U     0      0        0 eth0
5.0.0.0         *               255.0.0.0       U     0      0        0 eth1
root@OpenWrt:/#

Regards,
Ratnam.

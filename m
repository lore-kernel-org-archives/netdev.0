From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: alx: Wrong MAC address for AR8161
Date: Mon, 21 Apr 2014 14:47:41 +0300
Message-ID: <1625626.OzlbaoGxG0@spock>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natalenko.name ([78.47.77.148]:45515 "EHLO natalenko.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbaDUL47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2014 07:56:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I've got the following ethernet card in my laptop:

===
02:00.0 Ethernet controller: Qualcomm Atheros AR8161 Gigabit Ethernet (rev 10)
===

And it gets wrong MAC address with mainlined alx driver:

===
8: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP 
group default qlen 1000
    link/ether 00:13:74:00:00:00 brd ff:ff:ff:ff:ff:ff
===

Before alx got merged into upstream I used out-of-tree alx driver from here 
[1], and the MAC address was 84:8f:69:d3:a6:09.

Setting MAC address manually to 84:8f:69:d3:a6:09 via ip link set works OK, 
but when I rmmod and then modprobe alx module, I get 00:13:74:00:00:00 again.

Kernels 3.13/3.14 are affected.

What could be wrong and how could it be fixed? Any additional info needed?

[1] http://www.linuxfoundation.org/collaborate/workgroups/networking/alx

-- 
Oleksandr post-factum Natalenko, MSc
pf-kernel community
https://natalenko.name/

From: Frank Steve <rimifrank@yahoo.com>
Subject: PacketFence: Interfaces & Networks Configuration Disappear on Restart
Date: Wed, 19 Jun 2013 15:16:49 +0000 (UTC)
Message-ID: <loom.20130619T170901-353@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41836 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756640Ab3FSPUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 11:20:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UpKB1-0006c2-Dm
	for netdev@vger.kernel.org; Wed, 19 Jun 2013 17:20:03 +0200
Received: from 41.215.128.215 ([41.215.128.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:20:03 +0200
Received: from rimifrank by 41.215.128.215 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:20:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am experiencing some strange behavior in PacketFence configuration.

I have installed packetfence in Ubuntu 12.10. Everytime i restart the Ubuntu
server the settings/configuration i had made under interfaces & networks
disappear. On the linux box it shows no ip defined on the sub-interfaces; i
have to keep on re-configuring. Anyone with idea on how to resolve this?

root@ecsnacsvr:~# ifconfig
eth0      Link encap:Ethernet  HWaddr e8:39:35:39:c1:eb
          inet addr:10.10.0.10  Bcast:10.10.0.15  Mask:255.255.255.240
          inet6 addr: fe80::ea39:35ff:fe39:c1eb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:11961 errors:0 dropped:0 overruns:0 frame:0
          TX packets:294 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1191641 (1.1 MB)  TX bytes:45370 (45.3 KB)

eth0.10   Link encap:Ethernet  HWaddr e8:39:35:39:c1:eb
          inet6 addr: fe80::ea39:35ff:fe39:c1eb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4176 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:196380 (196.3 KB)  TX bytes:3810 (3.8 KB)

eth0.20   Link encap:Ethernet  HWaddr e8:39:35:39:c1:eb
          inet6 addr: fe80::ea39:35ff:fe39:c1eb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1021 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:54723 (54.7 KB)  TX bytes:3810 (3.8 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:405 errors:0 dropped:0 overruns:0 frame:0
          TX packets:405 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1017697 (1.0 MB)  TX bytes:1017697 (1.0 MB)

Regards,
Frank

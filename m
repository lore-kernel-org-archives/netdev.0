From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: ifconfig doesn't show assignment ip-addresses
Date: Tue, 10 Dec 2013 12:52:20 +0100
Message-ID: <52A70074.2000607@enst-bretagne.fr>
References: <20131209153238.GA10317@omega> <20131210105741.GA2469@minipsycho.orion> <20131210110648.GA18196@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:48124 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725Ab3LJLwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 06:52:23 -0500
In-Reply-To: <20131210110648.GA18196@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is not a lowpan specific problem, I have the same here:

$ /sbin/ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 08:00:27:27:58:92
          inet adr:192.168.56.2  Bcast:192.168.56.255
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:494 errors:0 dropped:0 overruns:0 frame:0
          TX packets:380 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 lg file transmission:1000
          RX bytes:41584 (40.6 KiB)  TX bytes:51017 (49.8 KiB)

$ ip -6 addr show eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:470:51a3:666::666/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe27:5892/64 scope link
       valid_lft forever preferred_lft forever

(standard ethernet interface of a virtual machine).

Regards,

Florent.

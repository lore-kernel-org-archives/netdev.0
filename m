From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 16:08:14 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com><20110711130729.607d461e@nehalam.ftrdhcpuser.net><925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:22981 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab1GKVIQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:08:16 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What about console dmesg output.

I should probably turn off all firewall logging so I don't fill the ring
buffer with my log messages in, like, the first couple minutes after a
boot.  :)

> Please retest with a standard upstream kernel (like 2.6.39.2).

That's gonna take a while to put together a whole test environment with
the latest kernel.org kernel.

> The bridge itself puts the device into promiscuous mode already.

Uhmmmm - no it didn't.  Remember, I put br0 into promiscuous mode myself
by hand - take a look at this.  Note eth0 and eth1 are not in
promiscuous mode.  I wonder how it would behave if I put the physical
devices into promiscuous mode and left br0 alone?  This I can easily
test during off hours.  

[root@ehac-fw2011 gregs]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state
DOWN qlen 1000
    link/ether 00:0e:7f:2d:d0:6e brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:0d:88:31:d8:24 brd ff:ff:ff:ff:ff:ff
5: br0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc prio
state UNKNOWN
    link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff
[root@ehac-fw2011 gregs]#
  
- Greg


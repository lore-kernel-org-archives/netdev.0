From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: PRIO qdisc classes and filters
Date: Sat, 24 Dec 2011 14:36:33 -0500
Message-ID: <1324755393.3200.31.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:61870 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782Ab1LXTgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 14:36:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  Sorry for such pestering; I really do spend a lot of time
in Internet research before posting believe it or not!

Is it my imagination or is it not possible to attach a filter to a PRIO
qdisc class? I only succeed in attaching filters to root or the qdisc
itself.

tc qdisc add dev eth1 root handle 2: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
root@testswitch01:~# tc filter add dev eth1 parent 2:2 protocol ip prio 1 u32 match u32 0 0 flowid 1:1
RTNETLINK answers: Invalid argument
We have an error talking to the kernel
root@testswitch01:~# tc filter add dev eth1 parent 2:0 protocol ip prio 1 u32 match u32 0 0 flowid 1:0
root@testswitch01:~# tc filter del dev eth1 parent 2:0 protocol ip prio 1 u32 match u32 0 0 flowid 1:0
root@testswitch01:~# tc filter add dev eth1 parent 2:1 protocol ip prio 1 u32 match u32 0 0 flowid 1:0
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

I am trying to use PRIO simply as a container so that I can apply two
separate filters to the same traffic.  Thanks - John

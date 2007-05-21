From: "Primiano Tucci" <mail@primianotucci.com>
Subject: Ethernet frames filtering/relaying. Help needed
Date: Mon, 21 May 2007 16:49:56 +0200
Message-ID: <000201c79bb7$4c97b680$0201a8c0@airforce1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from joe.tiscali.it ([213.205.33.54]:52721 "EHLO joe.tiscali.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756142AbXEUOzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 10:55:51 -0400
Received: from airforce1 (84.222.248.98) by joe.tiscali.it (7.2.079)
        id 462DD29A00413D5F for netdev@vger.kernel.org; Mon, 21 May 2007 16:49:57 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all, I'm new to this Mailing list
Some days ago I started development of a new 2.6 network driver (formerly it
should be a decentered Network Load Balancing driver).
I'm not too much familiar with kernel networking, so I'm asking you what's
the best approach to do something like this:
- Allocate a new tun interface... let's say tun0 (no problems with this
step)
- Monitor layer2 traffic on an existing device(let's say eth0).
-Catch all Ethernet frames arrived on eth0 with an arbitrary destination MAC
address.... let's say catch all the frames that has 01:00:02:03:04:05 as
destination MAC addr.
-Extrapolate the IP datagram contained in the frames and push it in tun0

I need some suggestions about the best approach to catch and relay Ethernet
frames on eth0. Should I use netfilter? Should I not?
Any help will be appreciated. Thanks

Primiano Tucci



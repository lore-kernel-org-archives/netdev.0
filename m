From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv8 0/2] Interface group patches, take 8
Date: Thu,  6 Mar 2008 15:02:52 +0100
Message-ID: <12048121721361-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:49460 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbYCFOCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 09:02:53 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id B8520C1303
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 15:02:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is a subset of our ifgroup patches, the folowing two patches belongs to
the core part.

Each net device has an ifgroup value which is zero by default (unset), and can
be set via sysfs (e.g. /sys/class/net/eth0/ifgroup).

Previously I posted a patch for the ip command in iproute2 which can be another
interface to show and set the ifgroup of the device [1].

There is also a netfilter ifgroup match which is accepted by Patrick [2] [3]


References:
 [1] http://marc.info/?l=linux-netdev&m=119798102017216&w=2
 [2] http://marc.info/?l=linux-netdev&m=119635294305131&w=2
 [3] http://marc.info/?l=linux-netdev&m=119635294805150&w=2
--
Laszlo Attila Toth

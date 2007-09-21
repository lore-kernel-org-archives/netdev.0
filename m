From: John Reiser <jreiser@BitWagon.com>
Subject: want same order in /sys/class/net/eth as /sys/bus/pci/devices
Date: Fri, 21 Sep 2007 08:59:53 -0700
Message-ID: <46F3EA79.4060700@BitWagon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jade.aracnet.com ([216.99.193.136]:57050 "EHLO jade.aracnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754925AbXIUQGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 12:06:44 -0400
Received: from [192.168.0.4] (216-99-213-225.dsl.aracnet.com [216.99.213.225])
	(authenticated bits=0)
	by jade.aracnet.com (8.13.6/8.12.8) with ESMTP id l8LFxclX021187
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 08:59:38 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd like to see the same order of devices in /sys/class/net/eth*
as in /sys/bus/pci/devices.  This would make administration easier.
On Fedora 8 tests, the order I see is reversed:
  http://bugzilla.redhat.com/show_bug.cgi?id=291431

Perhaps the reversal is a result of the alias order listed in
/etc/modprobe.conf.  But the alias order was obtained from some
source.  Was the first reversal due to a user-space program
(such as the anaconda installer), or due to something within
the kernel?

-- 
John Reiser, jreiser@BitWagon.com

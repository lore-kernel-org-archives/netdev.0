From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: sysfs warnings, reserved names
Date: Fri, 17 Feb 2012 12:14:14 +0200
Message-ID: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57451 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346Ab2BQKZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 05:25:16 -0500
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id CEADB2EC063
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 12:14:14 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just did a test:

ip link set dev eth1 name default

And got a lot of (expected) sysfs warnings:
[1068625.677143] sysctl table check failed: 
/net/ipv4/conf/default/promote_secondaries  Sysctl already exists
[1068625.677151] Pid: 18106, comm: ip Not tainted 3.2.4-centaur #1
and etc

Kernel 3.2.4, but i guess it doesn't matter much.
Maybe such names (as all and default) should be "reserved"?
Or it is ok like that?

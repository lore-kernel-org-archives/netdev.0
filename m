From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: rcu_sched_state detected stall, no stack trace
Date: Wed, 11 Apr 2012 07:50:37 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2068822FE@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:54238 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754958Ab2DKCUj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 22:20:39 -0400
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id q3B2KcXa016885
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 02:20:38 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am running vanilla kernel 3.0.23 . I am trying to add some 6K and more
IPv6 IPSec tunnels.
I am getting these warnings in dmesg close to 6k tunnels, after which
the kernel hangs and have to reboot the kernel.

[ 1511.045261] INFO: rcu_sched_state detected stall on CPU 4 (t=300000
jiffies) [ 1534.736899] INFO: rcu_bh_state detected stalls on
CPUs/tasks: { 4} (detected by 13, t=300002 jiffies)

I am not getting any back-trace also, to figure out what is actually
causing the stall to happen.

Could someone help to figure out the issue.

Regards,
Prashant

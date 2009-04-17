From: Radu Rendec <radu.rendec@ines.ro>
Subject: htb parallelism on multi-core platforms
Date: Fri, 17 Apr 2009 13:40:44 +0300
Message-ID: <1239964844.21569.57.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:59321 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756247AbZDQLS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 07:18:28 -0400
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by blade.ines.ro (8.14.2/8.14.2) with ESMTP id n3HAeiqX006768
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 13:40:45 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm using htb on a dedicated shaping machine. Under heavy traffic (high
packet rate) all htb work is done on a single cpu - only one ksoftirqd
is consuming cpu power.

I have limited network stack knowledge, but I guess all htb work for a
particular interface is done on the same softirq context. Of course this
does not scale with multiple cpus, since only one of them would be used.

Is there any (simple) approach to distribute htb work (for one
interface) on multiple cpus?

Thanks,

Radu Rendec



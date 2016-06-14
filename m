From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Avoiding bridge flood of multicast when L2 switch is used
Date: Tue, 14 Jun 2016 16:12:32 -0400
Message-ID: <57606530.6030208@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	<john.r.fastabend@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:59449 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbcFNUM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:12:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev experts,

When there is a L2 switch underneath the network interface a flooding of
multicast at the bridge interface results in one copy of this going through each
of the slave resulting in multiple multicast packets reaching the underlying switch.
L2 switch also duplicates the multicast packet on each egress port as done
in software bridge. This is undesirable as it reduces the available bandwidth to
half when multicast packets are involved.

Is there something that can be done to avoid software bridge flooding mulicast
through a ip command or similar or to be done in the network driver? I have a TODO
item to add dsa support in our netcp driver. If this is already solved by dsa, I can
handle it as part of this work. 

Thanks in advance for your response! 
-- 
Murali Karicheri
Linux Kernel, Keystone

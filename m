From: Xia Yang <xiayang@ntu.edu.sg>
Subject: Removing DAD in IPv6
Date: Mon, 01 Oct 2007 11:53:27 +0800
Message-ID: <1191210807.25398.18.camel@orbit6>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp2.ntu.edu.sg ([155.69.5.9]:35853 "EHLO exsmtp2.ntu.edu.sg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbXJAEJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 00:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am new to this list, so please forgive me if I say anything
inappropriate.

I am working on a mobility testbed based on IPv6. In order to improve
the performance, I would like to remove the DAD process during the
auto-configuration process of an IPv6 address for my testbed. 

During my experiment, I observed that when an address is configured
based on a router advertisement, the outgoing packets can be sent out
immediately. But the packets destined to local node can only be received
after some time (about 1 sec). I found the lost packets are discarded in
the kernel and never make it to the transport layer. I suspect it is
caused by the DAD process.

I would like to ask for help on how to remove or disable the DAD process
properly, as long as the node can send, receive and forward packets
immediately after a new IPv6 address is generated. Any pointer is
appreciated. Thanks a lot in advance!

Best Regards,

Xia Yang


From: =?UTF-8?Q?=22Conch=C3=BAr_Navid=22?= <conchur@web.de>
Subject: Aw: IP-Packets over wrong Ethernet device
Date: Fri, 20 Jun 2014 10:22:23 +0200
Message-ID: <trinity-e658ef1e-b2fd-4ed2-8b80-4056c6fb2901-1403252543405@3capp-webde-bs53>
References: <trinity-115b0f38-53ca-4333-9f3d-0cca5ea770d9-1403251544932@3capp-webde-bs53>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:59879 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934676AbaFTIWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 04:22:25 -0400
In-Reply-To: <trinity-115b0f38-53ca-4333-9f3d-0cca5ea770d9-1403251544932@3capp-webde-bs53>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> A dump on the management network ethernet interface (192.168.1.x/24) shows me that there was really an ARP request of the sender for 192.168.200.x/24 on this interface which was replied by the receiver on that interface. Is there a way to disable this reply on the "wrong" interface without using ARP-tables?

This is done by setting arp_ignore to 2 in sysctl (for the correct interfaces):

sysctl -a|grep arp_ignore
sysctl -w net.ipv4.conf.eth5.arp_ignore=2

Thanks

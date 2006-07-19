From: Georg Wicherski <georg-wicherski@pixel-house.net>
Subject: Bind TUN to IPv4 Subnet
Date: Wed, 19 Jul 2006 17:26:49 +0200
Message-ID: <44BE4F39.70405@pixel-house.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dd3112.kasserver.com ([81.209.184.234]:44210 "EHLO
	dd3112.kasserver.com") by vger.kernel.org with ESMTP
	id S964871AbWGSP0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 11:26:43 -0400
Received: from [192.168.108.105] (public.eurecom.fr [193.55.113.196])
	by dd3112.kasserver.com (Postfix) with ESMTP id 1D45A1B9EB8
	for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 17:26:42 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Folks,

I need to bind a TUN device previously created by open("/dev/net/tun",
O_RW) to a subnet, let's say 10.254.0.0/16. The ultimate goal is to have
a tunnel endpoint for a IPv4 tunnel, where I can after writing the
packet which came over the tunnel to the TUN device use an arbitary
userland socket bound to one of the 2^16 IPs or just all of them with
with INADDR_ANY.

What is the (sequence?) of ioctl's to configure the TUN device into
`listening' on a whole subnet? If possible, I want to just specify a
base address and a prefix length.

Digging into the curent 2.6.x kernel sources didn't help me much (yes,
they are badly commented).


Thanks,
Georg Wicherski


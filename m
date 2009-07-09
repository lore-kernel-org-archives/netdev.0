From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 0/5] Add support for software UDP
 fragmentation offload(UFO)
Date: Thu, 09 Jul 2009 11:09:41 -0700
Message-ID: <1247162981.8649.89.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53670 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086AbZGISJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:09:48 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69I4HsG014234
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:04:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69I9jXA241650
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69I9ilv032267
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following set of patches fixes support for UDP fragmentation offload
in the core networking stack to send/receive large UDP packets over UFO
enabled devices and fallback to software UFO when the outgoing device 
doesn't support UFO.
These patches enable setting UFO on virtio-net and tap devices and allow
large UDP packets to be sent between guest to host and inter guest under
KVM.

[PATCH net-next-2.6 1/5] udpv4: Handle large incoming UDP/IPv4 packets and support software UFO.
[PATCH net-next-2.6 2/5] udpv6: Fix HW checksum support for outgoing UFO packets
[PATCH net-next-2.6 3/5] udpv6: Fix gso_size setting in ip6_ufo_append_data
[PATCH net-next-2.6 4/5] udpv6: Remove unused skb argument of ipv6_select_ident()
[PATCH net-next-2.6 5/5] udpv6: Handle large incoming UDP/IPv6 packets and support software UFO

Thanks
Sridhar




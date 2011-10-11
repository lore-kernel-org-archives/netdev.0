From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 0/2] ipv6: IPsec pmtu/fragmentation fixes
Date: Tue, 11 Oct 2011 13:42:51 +0200
Message-ID: <20111011114251.GH1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53318 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246Ab1JKLmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:42:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes two issues for IPsec on ipv6. These issues
are arround, basically forever.

The patchset is based on current net-next/master.

1) Fix for a IPv6 IPsec slowpath fragmentation problem.
   Already fixed for IPv4 with
   git commit 353e5c9 (ipv4: Fix IPsec slowpath fragmentation problem).

2) Fix an incorrect update of the path mtu on IPv6 IPsec.
   Already fixed for IPv4 with
   git commit b00897b (xfrm4: Don't call icmp_send on local error).

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][0/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:43:20 +0900
Message-ID: <20061124144320.92b2214e.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:18905 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934356AbWKXFn2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:28 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David and Herbert,

I send patches to support inter family ipsec tunnel.
These patches are based on the great work by
Miika Komu and Diego Beltrami.
http://infrahip.hiit.fi/beet/2.6.16.5/

They had done almost of the patch. I fixed IPv4 and IPv6 header
process and mtu handling. 

These are summary of the following patches.

[1/7] add encapsulating address family
[2/7] add netlink interface of the family
[3/7] add pfkeyv2 interface
[4/7] add IPv6 over IPv4 IPsec tunnel
      with changing the creating bundle process and
      the header handling.
[5/7] add IPv4 over IPv6 IPsec tunnel with same way
[6/7] fix mtu calculation of IPv4 datagram
[7/7] fix mtu calculation and the check for IPv6 datagram

I checked these patches work well with manual configuration.
They can be applied to net-2.6.20.

Best regards

--
Kazunori Miyazawa




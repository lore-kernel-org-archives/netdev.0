From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][0/6] fix conflict of device tunnels with the ipsec
 tunnel
Date: Thu, 8 Feb 2007 17:03:24 +0900
Message-ID: <20070208170324.3e3a4d59.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:49194 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161542AbXBHILZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David and Herbert,

Thank you for applying our patches with the fix.

I send patches to fix conflict of device tunnels with the inter
address family ipsec tunnel. Yoshifuji-san and Kozakai-san
noticed me of the confliction.

I adopt same approach of tunnel4.c and tunnel6.c. I extend them
to support inter address family.

We need this to use ipcomp with inter address family tunnel.

[1/6] extending xfrm4_tunnel utility to support inter address family for "sit"
[2/6] extending xfrm6_tunnel utility to support inter address family
[3/6] fix to refer encap_family when comparing the kernel generated xfrm_state
[4/6] changing "ipip tunnel" and xfrm4_tunnel to the API
[5/6] changing "ip6_tunnel" and xfrm6_tunnel to the API
[6/6] make "sit tunnel" use xfrm4_tunnel_register 

Best regards,

--
Kazunori Miyazawa


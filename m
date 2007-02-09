From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][0/4] fix conflict of device tunnels with the ipsec
 tunnel
Date: Fri, 9 Feb 2007 16:37:16 +0900
Message-ID: <20070209163716.eb7ced2c.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:59922 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1946175AbXBIHhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 02:37:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I fixed and reconstruted the patch.

# I understood my mistake. I'm ashamed.

[1/4] changing API of xfrm4_tunnel_register
[2/4] make sit use the xfrm4_tunnel_register
[3/4] changing API of xfrm6_tunnel_register
[4/4] Fix the address family to refer encap_family

--
Kazunori Miyazawa

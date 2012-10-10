From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Sparse warnings in IPV6 GRE
Date: Wed, 10 Oct 2012 11:54:02 -0700
Message-ID: <20121010115402.0f759108@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37070 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab2JJSym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 14:54:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like IPV6 GRE is probably not byte-endian safe?

  CHECK   net/ipv6/ip6_gre.c
net/ipv6/ip6_gre.c:472:37: warning: restricted __be32 degrades to integer
net/ipv6/ip6_gre.c:484:23: warning: restricted __be32 degrades to integer
net/ipv6/ip6_gre.c:964:26: warning: incorrect type in assignment (different base types)
net/ipv6/ip6_gre.c:964:26:    expected unsigned char [unsigned] [addressable] [usertype] flowic_proto
net/ipv6/ip6_gre.c:964:26:    got restricted __be16 [usertype] protocol
net/ipv6/ip6_gre.c:1510:33: warning: incorrect type in assignment (different base types)
net/ipv6/ip6_gre.c:1510:33:    expected restricted __be32 [usertype] flowinfo
net/ipv6/ip6_gre.c:1510:33:    got unsigned int

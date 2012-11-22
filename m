From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request: ipsec 2012-11-22
Date: Thu, 22 Nov 2012 08:56:36 +0100
Message-ID: <1353570997-2571-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36438 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965189Ab2KVTej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:34:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request is intended for 3.7 and contains a single patch to
fix the IPsec gc threshold value for ipv4.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit a66fe1653f4e81c007a68ca975067432a42df05b:

  net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs (2012-11-07 21:12:26 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 703fb94ec58e0e8769380c2877a8a34aeb5b6c97:

  xfrm: Fix the gc threshold value for ipv4 (2012-11-13 09:15:07 +0100)

----------------------------------------------------------------
Steffen Klassert (1):
      xfrm: Fix the gc threshold value for ipv4

 include/net/xfrm.h      |    2 +-
 net/ipv4/route.c        |    2 +-
 net/ipv4/xfrm4_policy.c |   13 +------------
 3 files changed, 3 insertions(+), 14 deletions(-)

From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec-next v2 0/2] xfrm: make gc_thresh configurable in all
 namespaces
Date: Wed,  6 Feb 2013 10:46:13 +0100 (CET)
Message-ID: <cover.1360143430.git.mkubecek@suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58496 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab3BFJqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 04:46:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from original version:

- remove unused xfrm4_fini() to avoid section mismatch
- don't mark xfrm6_net_ops as __net_initdata to avoid section mismatch

Michal Kubecek (2):
  xfrm: remove unused xfrm4_policy_fini()
  xfrm: make gc_thresh configurable in all namespaces

 include/net/netns/ipv4.h |    1 +
 include/net/netns/ipv6.h |    1 +
 net/ipv4/xfrm4_policy.c  |   58 ++++++++++++++++++++++++++++++++++++----------
 net/ipv6/xfrm6_policy.c  |   52 +++++++++++++++++++++++++++++++++++++----
 4 files changed, 95 insertions(+), 17 deletions(-)

-- 
1.7.10.4

From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-12-22
Date: Tue, 22 Dec 2015 10:35:18 +0100
Message-ID: <1450776919-27715-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36976 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437AbbLVJfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 04:35:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just one patch to fix dst_entries_init with multiple namespaces.
>From Dan Streetman.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 5f6c99e0ab805d8ec9eda105822912d49aa1d409:

  net: phy: fix a bug in get_phy_c45_ids (2015-11-02 23:45:20 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to a8a572a6b5f2a79280d6e302cb3c1cb1fbaeb3e8:

  xfrm: dst_entries_init() per-net dst_ops (2015-11-03 08:42:57 +0100)

----------------------------------------------------------------
Dan Streetman (1):
      xfrm: dst_entries_init() per-net dst_ops

 net/ipv4/xfrm4_policy.c | 46 +++++++++++++++++++++++++++++++++---------
 net/ipv6/xfrm6_policy.c | 53 +++++++++++++++++++++++++++++++++++--------------
 net/xfrm/xfrm_policy.c  | 38 -----------------------------------
 3 files changed, 75 insertions(+), 62 deletions(-)

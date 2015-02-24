From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v4 0/2] nft hash resize fixes
Date: Tue, 24 Feb 2015 13:07:05 -0500
Message-ID: <1424801227-17320-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay06.akamai.com ([96.6.114.98]:40831 "EHLO
	prod-mail-xrelay06.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbbBXSHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 13:07:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes nft hash set expansion problem.

v4:
  * reorder commits for bisect-ability
v3:
  * Renames NFT_HASH_MAX_ELEMENTS to NFT_HASH_MAX_BUCKETS
  * Add Acked-by for Thomas

Josh Hunt (2):
  nft_hash: define max_shift rhashtable parameter
  rhashtable: require max_shift if grow_decision defined

 lib/rhashtable.c         |    3 ++-
 net/netfilter/nft_hash.c |    4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

-- 
1.7.9.5

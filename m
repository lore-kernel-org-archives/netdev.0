From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v3 0/2] nft hash resize fixes
Date: Tue, 24 Feb 2015 12:25:34 -0500
Message-ID: <1424798736-11857-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:64686 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752875AbbBXRZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:25:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:
 * Renames NFT_HASH_MAX_ELEMENTS to NFT_HASH_MAX_BUCKETS
 * Add Acked-by for Thomas

Josh Hunt (2):
  rhashtable: require max_shift if grow_decision defined
  nft_hash: define max_shift rhashtable parameter

 lib/rhashtable.c         |    3 ++-
 net/netfilter/nft_hash.c |    4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

-- 
1.7.9.5

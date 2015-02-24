From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v2 0/2] nft hash resize fixes
Date: Tue, 24 Feb 2015 11:10:56 -0500
Message-ID: <1424794259-30241-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the minimal set of changes to get rhashtable expansion working with nft
hash sets. I will provide a followup patchset allowing the user to tune the
max size of the set.


Josh Hunt (2):
  rhashtable: require max_shift if grow_decision defined
  nft_hash: define max_shift rhashtable parameter

 lib/rhashtable.c         |    3 ++-
 net/netfilter/nft_hash.c |    4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

-- 
1.7.9.5


From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 0/2] ipv4: fib_select_default changes
Date: Wed, 22 Jul 2015 10:43:21 +0300
Message-ID: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38473 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755903AbbGVHoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 03:44:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains 2 changes for the alternative routes,
one to add tb_id/fa_slen check needed after the recent
fib_trie optimizations for fib aliases and the second
change attempts to support alternative routes with TOS
requirement.

	Sorry that I don't have access to the original
report from Hagen Paul Pfeifer. I hope he will see this
change.

	The second change adds fa_default field to the
fib aliases (which can be many) and if the feature to
filter the alternative routes by TOS is not worth it,
this second patch can be scrapped.

Julian Anastasov (2):
  ipv4: fib_select_default should match the prefix
  ipv4: consider TOS in fib_select_default

 include/net/ip_fib.h     |  3 +--
 net/ipv4/fib_lookup.h    |  1 +
 net/ipv4/fib_semantics.c | 41 ++++++++++++++++++++++++++++++-----------
 net/ipv4/fib_trie.c      |  3 ++-
 net/ipv4/route.c         |  2 +-
 5 files changed, 35 insertions(+), 15 deletions(-)

-- 
1.9.3

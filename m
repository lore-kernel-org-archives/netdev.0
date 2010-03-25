From: kaber@trash.net
Subject: [PATCH 0/4] netfilter fixes
Date: Thu, 25 Mar 2010 18:54:42 +0100
Message-ID: <1269539686-3885-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56920 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab0CYRyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are four netfilter fixes for 2.6.34, fixing:

- a regression in the recent match, introduced during 2.6.33
- a crash after a failed memory allocation in xt_hashlimit seq_file handling
- an incorrect hook priority of the IPv6 raw table
- a missing 'break' in the IPv6 xt_hashlimit netmask calculation

 include/linux/netfilter_ipv6.h    |    1 +
 net/ipv6/netfilter/ip6table_raw.c |    2 +-
 net/netfilter/xt_hashlimit.c      |    4 +++-
 net/netfilter/xt_recent.c         |    2 +-
 4 files changed, 6 insertions(+), 3 deletions(-)

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

PS: this is my first "live" attempt at using git-send-email, so appologies
in advance in case I made any mistakes.

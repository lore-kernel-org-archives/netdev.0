From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20150603
Date: Wed,  3 Jun 2015 16:13:56 +0200
Message-ID: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:44189 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932550AbbFCOQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have our second batch of patches intended for net-next.

In this patchset you won't find any new features, but quite some code
cleanup work, a bunch of code style fixes and also comments corrections
by Markus Pargmann.

Moreover you have a patch from Sven Eckelmann removing an unnecessary
NULL check in batadv_iv_ogm_update_seqnos().

Please pull or let me know of any problem!

Thanks a lot,
	Antonio

The following changes since commit df905ceae3883f024282d00824ce33040097ac86:

  Merge branch 'sfc-next' (2015-06-02 12:57:39 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to f372d09059a67f57b3d2b5eab8c05b0ddb8ca92f:

  batman-adv: Remove unnecessary ret variable in algo_register (2015-06-03 15:57:25 +0200)

----------------------------------------------------------------
Included changes:
- code re-arrangement for better reading and understanding
- code style fixups
- comments corrections
- remove unnecessary NULL check in batadv_iv_ogm_update_seqnos()
- make boolean functions explicitly return a bool result
- remove unnecessary variables in algo_register() and algo_select()

----------------------------------------------------------------
Markus Pargmann (11):
      batman-adv: iv_ogm_aggregate_new, simplify error handling
      batman-adv: iv_ogm_queue_add, Simplify expressions
      batman-adv: iv_ogm_orig_update, style, add missing brackets
      batman-adv: iv_ogm, Fix dup_status comment
      batman-adv: iv_ogm, fix coding style
      batman-adv: iv_ogm, fix comment function name
      batman-adv: types, Fix comment on bcast_own
      batman-adv: main, Convert is_my_mac() to bool
      batman-adv: main, batadv_compare_eth return bool
      batman-adv: Remove unnecessary ret variable
      batman-adv: Remove unnecessary ret variable in algo_register

Sven Eckelmann (1):
      batman-adv: Remove unnecessary check for orig_ifinfo not NULL

 net/batman-adv/bat_iv_ogm.c | 46 ++++++++++++++++++++++-----------------------
 net/batman-adv/main.c       | 29 ++++++++++++----------------
 net/batman-adv/main.h       |  4 ++--
 net/batman-adv/types.h      |  7 ++++---
 4 files changed, 41 insertions(+), 45 deletions(-)

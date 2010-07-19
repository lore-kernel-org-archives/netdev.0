From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC 0/2] netfilter: xtables: CONDITION target implementation
Date: Mon, 19 Jul 2010 17:15:45 +0300
Message-ID: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:36866 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933591Ab0GSOQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 10:16:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <coelho@testbed.(none)>

Hi all,

As discussed earlier, I've been looking for a way to enable and disable the
condition match automatically, in the netfilter tables themselves (ie. without
the need to use procfs).

This is my initial implementation.  Please let me know how it looks.  The first
patch is based on the xt_condition patch that Jan sent to the list (but which
has not been finalized for inclusion yet).  Once the condition match gets
applied, I'll forward port my patch and submit it again.

Cheers,
Luca.

Luciano Coelho (2):
  netfilter: xt_condition: export list management code
  netfilter: xtables: implement CONDITION target

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_CONDITION.h |   39 +++++++++++
 include/linux/netfilter/xt_condition.h |   17 +++++-
 net/netfilter/Kconfig                  |   12 ++++
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_CONDITION.c           |  112 ++++++++++++++++++++++++++++++++
 net/netfilter/xt_condition.c           |   82 ++++++++++++++----------
 7 files changed, 229 insertions(+), 35 deletions(-)
 create mode 100644 include/linux/netfilter/xt_CONDITION.h
 create mode 100644 net/netfilter/xt_CONDITION.c


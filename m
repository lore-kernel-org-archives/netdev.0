From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC v2 0/1] netfilter: xtables: xt_condition inclusion with namespace fix
Date: Fri, 23 Jul 2010 17:28:39 +0300
Message-ID: <1279895320-12958-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:23831 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000Ab0GWO2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 10:28:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a respin of the patch Jan sent to the list some time ago.  I've made
the changes proposed by Patrick in order to support multiple namespaces
correctly.

I still need to reapply my condition target and the u32 changes to the
condition on top of this, but I'd like to get some comments before I continue.

In v2 I've made a few changes as discussed in the review:

  * Removed per-netns module parameters
  * Use par->net instead of current->nsproxy->net_ns
  * Fix file-leak in procfs when exiting the netns

Please let me know how it looks after these changes.

Cheers,
Luca.

Luciano Coelho (1):
  netfilter: xtables: inclusion of xt_condition

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_condition.h |   14 ++
 net/netfilter/Kconfig                  |    8 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_condition.c           |  265 ++++++++++++++++++++++++++++++++
 5 files changed, 289 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_condition.h
 create mode 100644 net/netfilter/xt_condition.c


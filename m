From: luciano.coelho@nokia.com
Subject: [PATCH 0/2] netfilter: xtables: xt_condition inclusion and change to u32
Date: Thu,  5 Aug 2010 17:41:07 +0300
Message-ID: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:44551 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933497Ab0HEOlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 10:41:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <luciano.coelho@nokia.com>

Hi again,

Here is the xt_condition patch, hopefully for inclusion this time.

When these patches get accepted, I'll send the implementation of the condition
target, as discussed before.

In RFC v2 I've made a few changes as discussed in the review:

  * Removed per-netns module parameters
  * Use par->net instead of current->nsproxy->net_ns
  * Fix file-leak in procfs when exiting the netns

I didn't get any more comments in RFC v2, so I assume it is okay to send it for
inclusion.

>From [RFC v2] to [PATCH], I've only rebased and added a new patch to support
u32 instead of boolean as the value for the condition.

Cheers,
Luca.

PS: I've been on vacation, that's why it took sometime to submit this patch again.


Luciano Coelho (2):
  netfilter: xtables: inclusion of xt_condition
  netfilter: xt_condition: change the value from boolean to u32

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_condition.h |   15 ++
 net/netfilter/Kconfig                  |    8 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_condition.c           |  268 ++++++++++++++++++++++++++++++++
 5 files changed, 293 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_condition.h
 create mode 100644 net/netfilter/xt_condition.c


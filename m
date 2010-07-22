From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC 0/1] netfilter: xtables: xt_condition inclusion with namespace fix
Date: Thu, 22 Jul 2010 17:09:17 +0300
Message-ID: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is a respin of the patch Jan sent to the list some time ago.  I've made
the changes proposed by Patrick in order to support multiple namespaces
correctly.

I still need to reapply my condition target and the u32 changes to the
condition on top of this, but I'd like to get some comments before I continue.

Please let me know how this looks.

Cheers,
Luca.

Luciano Coelho (1):
  netfilter: xtables: inclusion of xt_condition

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_condition.h |   14 ++
 net/netfilter/Kconfig                  |    8 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_condition.c           |  294 ++++++++++++++++++++++++++++++++
 5 files changed, 318 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_condition.h
 create mode 100644 net/netfilter/xt_condition.c


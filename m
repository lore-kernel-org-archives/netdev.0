From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [PATCH 0/1] netfilter: xt_condition: add condition target
Date: Thu, 12 Aug 2010 09:37:00 +0300
Message-ID: <1281595021-24310-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com, janne.ylalehto@nokia.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

So here's my patch to include the condition target in the existing condition
module.  This patch is supposed to be applied on top of the previous
xt_condition patches I submitted and is intended for 2.6.37 (I'll resend all
the 3 patches when the next tree starts accepting patches again).

One thing that came to my mind was whether it would make sense to rename this
match/target combo to "variable" instead of "condition".  To me it makes more
sense to call it variable than condition, since I have changed the value from
boolean to u32.  On the other hand, it could become very confusing because it
used to be called condition in its xtables-addons days...

Your comments are appreciated!

Cheers,
Luca.

Luciano Coelho (1):
  netfilter: xt_condition: add condition target support

 include/linux/netfilter/xt_condition.h |   13 ++-
 net/netfilter/Kconfig                  |   19 ++--
 net/netfilter/Makefile                 |    2 +-
 net/netfilter/xt_condition.c           |  194 +++++++++++++++++++++++---------
 4 files changed, 165 insertions(+), 63 deletions(-)


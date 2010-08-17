From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [PATCH RESEND 0/3] netfilter: xtables: inclusion of condition match and target
Date: Tue, 17 Aug 2010 11:36:50 +0300
Message-ID: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, sameo@linux.intel.com, janne.ylalehto@nokia.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm resending these three patches now that the net-next is open for development
again.  These patches include the xt_condition match and target.

Please integrate if everything is okay.

Cheers,
Luca.

Luciano Coelho (3):
  netfilter: xtables: inclusion of xt_condition
  netfilter: xt_condition: change the value from boolean to u32
  netfilter: xt_condition: add condition target support

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_condition.h |   26 +++
 net/netfilter/Kconfig                  |   11 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_condition.c           |  357 ++++++++++++++++++++++++++++++++
 5 files changed, 396 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_condition.h
 create mode 100644 net/netfilter/xt_condition.c


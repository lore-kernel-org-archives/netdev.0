From: kaber@trash.net
Subject: [PATCH 0/3] netfilter: netfilter fixes
Date: Thu, 20 May 2010 18:00:43 +0200
Message-ID: <1274371246-26760-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

following are three fixes for netfilter:

- handling of non-linear skbs in the SIP conntrack helper. This fixes tracking
  failures when running on the same machine as a SIP application that is
  producing non-linear skbs. Long term this should be fixed by using the string
  search API, but that is a bigger piece of work.

- fix for a race condition in nf_conntrack that might lead to conntrack entries
  marked as dead entering the hash tables, blocking new connections with similar
  keys.

- a fix for an incorrect comment about the checkentry return conventions.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/2] fib_trie: Minor fixes for table merge
Date: Thu, 12 Mar 2015 14:46:17 -0700
Message-ID: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108AbbCLVqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 17:46:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses two issues reported with the tables merged, the
first is a NULL pointer dereference, and the other is to remove a WARN_ON
and set the ordering for aliases from different tables with the same slen
values.

---

Alexander Duyck (2):
      fib_trie: Avoid NULL pointer if local table is not allocated
      fib_trie: Provide a deterministic order for fib_alias w/ tables merged


 net/ipv4/fib_frontend.c |    5 ++++-
 net/ipv4/fib_trie.c     |   28 +++++++++++++++++-----------
 2 files changed, 21 insertions(+), 12 deletions(-)

--

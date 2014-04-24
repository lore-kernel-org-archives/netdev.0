From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/5] BPF updates
Date: Thu, 24 Apr 2014 08:45:22 +0200
Message-ID: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaDXGpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 02:45:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had these cleanups still in my queue before the merge window.
The set is against net-next tree, but with 83d5b7ef99 ("net: filter:
initialize A and X registers") applied on top of it, so a merge
of net into net-next would be required *before* applying this set.

The main objective for these updates is that we get the code
a bit more readable/comprehensible and avoid one additional
instruction in the interpreter during fast-path.

Tested with Alexei's BPF test suite and seccomp test suite, no
issues found.

Thanks!

v1->v2:
 - Only changed patch 5 as to suggestion from Alexei
 - Rest is the same

Daniel Borkmann (5):
  net: filter: simplify label names from jump-table
  net: filter: misc/various cleanups
  net: filter: get rid of sock_fprog_kern
  net: filter: make register namings more comprehensible
  net: filter: optimize BPF migration for ARG1/CTX handling

 include/linux/filter.h |  60 ++++--
 net/core/filter.c      | 568 ++++++++++++++++++++++++-------------------------
 net/core/sock_diag.c   |   4 +-
 3 files changed, 329 insertions(+), 303 deletions(-)

-- 
1.7.11.7

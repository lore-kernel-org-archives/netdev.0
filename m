From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 0/3] BPF cleanups
Date: Thu,  1 May 2014 18:16:33 +0200
Message-ID: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbaEAQQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 12:16:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3:
 - Included Dave's feedback for unsigned long type in patch 3
 - Patch 1 and patch 2 unchanged since v1, dropped other
   two for now
v1->v2:
 - Only changed patch 5 as to suggestion from Alexei
 - Rest is the same

Daniel Borkmann (3):
  net: filter: simplify label names from jump-table
  net: filter: make register namings more comprehensible
  net: filter: misc/various cleanups

 include/linux/filter.h |  47 ++++-
 net/core/filter.c      | 538 +++++++++++++++++++++++++------------------------
 2 files changed, 309 insertions(+), 276 deletions(-)

-- 
1.7.11.7

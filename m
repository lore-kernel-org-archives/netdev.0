From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/5] SCTP fix/updates
Date: Wed, 30 Oct 2013 11:50:47 +0100
Message-ID: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab3J3KvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 06:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please see patch 5 for the main description/motivation, the rest just
brings in the needed functionality for that. Although this is actually
a fix, I've based it against net-next as some additional work for
fixing it was needed.

Thanks!

Daniel Borkmann (5):
  lib: crc32: clean up spacing in test cases
  lib: crc32: add functionality to combine two crc32{,c}s in GF(2)
  lib: crc32: add test cases for crc32{,c}_combine routines
  net: skb_checksum: allow custom update/combine for walking skb
  net: sctp: fix and consolidate SCTP checksumming code

 include/linux/crc32.h       |  40 ++++
 include/linux/skbuff.h      |  13 +-
 include/net/checksum.h      |   6 +
 include/net/sctp/checksum.h |  56 ++----
 lib/crc32.c                 | 453 +++++++++++++++++++++++++-------------------
 net/core/skbuff.c           |  31 ++-
 net/sctp/output.c           |   9 +-
 7 files changed, 350 insertions(+), 258 deletions(-)

-- 
1.8.3.1

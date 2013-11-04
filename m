From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] crc/csum follow-ups
Date: Mon,  4 Nov 2013 17:10:24 +0100
Message-ID: <cover.1383580331.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab3KDQKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 11:10:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  net: checksum: fix warning in skb_checksum
  lib: crc32: conditionally resched when running testcases
  lib: crc32: reduce number of tests for crc32{,c}_combine

 include/net/checksum.h | 5 +++++
 lib/crc32.c            | 7 +++++--
 net/core/skbuff.c      | 2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

-- 
1.8.3.1

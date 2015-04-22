From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net 0/2 v2] rhashtable rehashing fixes
Date: Wed, 22 Apr 2015 09:41:44 +0200
Message-ID: <cover.1429688383.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51877 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965414AbbDVHls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:41:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some rhashtable rehashing bugs found while testing with the
next rhashtable self-test queued up for the next devel cycle:

https://github.com/tgraf/net-next/commits/rht

v2:
 - Moved schedule_work() call into rhashtable_insert_rehash()

Thomas Graf (2):
  rhashtable: Schedule async resize when sync realloc fails
  rhashtable: Do not schedule more than one rehash if we can't grow
    further

 lib/rhashtable.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

-- 
2.3.5

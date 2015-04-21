From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net 0/2] rhashtable rehashing fixes
Date: Tue, 21 Apr 2015 14:55:33 +0200
Message-ID: <cover.1429620438.git.tgraf@suug.ch>
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44805 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbbDUMzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 08:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some rhashtable rehashing bugs found while testing with the
next rhashtable self-test queued up for the next devel cycle:

https://github.com/tgraf/net-next/commits/rht

Thomas Graf (2):
  rhashtable: Schedule async resize when sync realloc fails
  rhashtable: Do not schedule more than one rehash if we can't grow
    further

 include/linux/rhashtable.h | 2 ++
 lib/rhashtable.c           | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
2.3.5

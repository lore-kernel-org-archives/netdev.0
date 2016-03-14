From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 0/1] recvmmsg use-after-free fix
Date: Mon, 14 Mar 2016 09:56:34 -0300
Message-ID: <1457960195-4302-1-git-send-email-acme@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41093 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbcCNM4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 08:56:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

Hi David,

	Please consider applying,

- Arnaldo

Arnaldo Carvalho de Melo (1):
  net: Fix use after free in the recvmmsg exit path

 net/socket.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

-- 
2.5.0

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] rhashtable updates
Date: Fri, 20 Feb 2015 00:53:36 +0100
Message-ID: <cover.1424389682.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, johunt@akamai.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59409 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbbBSXxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 18:53:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  rhashtable: don't test for shrink on insert, expansion on delete
  rhashtable: better high order allocation attempts
  rhashtable: allow to unload test module

 lib/rhashtable.c      | 33 +++++++++++++++++++++------------
 lib/test_rhashtable.c |  5 +++++
 2 files changed, 26 insertions(+), 12 deletions(-)

-- 
1.9.3

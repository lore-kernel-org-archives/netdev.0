From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/4] net: af_unix: zerocopy stream bits
Date: Wed, 20 May 2015 17:35:04 +0200
Message-ID: <cover.1432135413.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34426 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751609AbbETPmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:42:25 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 225AC20A49
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:16 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9700E6801D6
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:15 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements zerocopy support for AF_UNIX SOCK_STREAM sockets.

Hannes Frederic Sowa (4):
  net: skbuff: add skb_append_pagefrags and use it
  net: af_unix: implement stream sendpage support
  net: make skb_splice_bits more configureable
  net: af_unix: implement splice for stream af_unix sockets

 include/linux/skbuff.h |  14 ++-
 net/core/skbuff.c      |  63 +++++++++----
 net/ipv4/ip_output.c   |   8 +-
 net/ipv4/tcp.c         |   5 +-
 net/unix/af_unix.c     | 246 ++++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 287 insertions(+), 49 deletions(-)

-- 
2.1.0

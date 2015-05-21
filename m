From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v3 net-next 0/4] net: af_unix: zerocopy stream bits
Date: Thu, 21 May 2015 16:59:57 +0200
Message-ID: <cover.1432220158.git.hannes@stressinduktion.org>
Cc: edumazet@google.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59720 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755334AbbEUPAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 11:00:08 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 796C62084F
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 11:00:07 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements zerocopy support for AF_UNIX SOCK_STREAM sockets.

Changelog in the specific patches. Thanks to all the reviewers!

Hannes Frederic Sowa (4):
  net: skbuff: add skb_append_pagefrags and use it
  net: af_unix: implement stream sendpage support
  net: make skb_splice_bits more configureable
  net: af_unix: implement splice for stream af_unix sockets

 fs/splice.c            |   1 +
 include/linux/skbuff.h |  14 ++-
 net/core/skbuff.c      |  64 +++++++++----
 net/ipv4/ip_output.c   |  15 +---
 net/ipv4/tcp.c         |   5 +-
 net/unix/af_unix.c     | 239 ++++++++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 284 insertions(+), 54 deletions(-)

-- 
2.1.0

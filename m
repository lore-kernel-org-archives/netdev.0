From: David Miller <davem@davemloft.net>
Subject: NAPI complete race backport?
Date: Thu, 16 Mar 2017 16:25:33 -0700 (PDT)
Message-ID: <20170316.162533.1242265332354542301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753465AbdCPXZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:25:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, could you please give me a backport of commit:

====================
>From 39e6c8208d7b6fb9d2047850fb3327db567b564b Mon Sep 17 00:00:00 2001
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 28 Feb 2017 10:34:50 -0800
Subject: [PATCH] net: solve a NAPI race
====================

for 4.10 and earlier?

This is before __napi_complete() is removed, so the empty poll list
handling in napi_complete_done() needs to be a bit different.

Thanks!

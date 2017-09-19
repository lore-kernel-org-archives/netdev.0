From: Florian Westphal <fw@strlen.de>
Subject: [net-next v2 0/4] test_rhashtable: don't allocate huge static array
Date: Wed, 20 Sep 2017 01:12:10 +0200
Message-ID: <20170919231214.2281-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57774 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751751AbdISXL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:11:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a test case for the rhlist interface.
While at it, cleanup current rhashtable test a bit and add a check
for max_size support.

No changes since v1, except in last patch.
kbuild robot complained about large onstack allocation caused by
struct rhltable when lockdep is enabled.

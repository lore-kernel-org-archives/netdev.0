From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/20] vm deadlock avoidance for NFS, NBD and iSCSI (take 7)
Date: Tue, 12 Sep 2006 17:25:49 +0200
Message-ID: <20060912143049.278065000@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	David Miller <davem@davemloft.net>,
	Rik van Riel <riel@redhat.com>,
	Daniel Phillips <phillips@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:20381 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S1751414AbWILPus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 11:50:48 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--

Yet another instance of my networked swap patches.

The patch-set consists of four parts:

 - patches 1-2; the basic 'framework' for deadlock avoidance
 - patches 3-9; implement swap over NFS
 - patches 10-13; implement swap over NBD
 - patches 14-20; implement swap over iSCSI

The iSCSI work depends on their .19 tree and does need some more work,
but does work in its current state.

As stated in previous posts, NFS and iSCSI survive service failures and
reconnect properly during heavy swapping.

Linus, when I mentioned swap over network to you in Ottawa, you said it was
a valid use case, that people actually do and want this. Can you agree with
the approach taken in these patches?

Peter


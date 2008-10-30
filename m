From: Paul Moore <paul.moore@hp.com>
Subject: [GIT PULL] Labeled networking fixes for 2.6.28
Date: Thu, 30 Oct 2008 13:10:13 -0400
Message-ID: <20081030170736.11396.46099.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:12960 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325AbYJ3RKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 13:10:15 -0400
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 9B3F538165
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:10:15 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three small fixes to solve compiler warnings and a possible run-time issue,
please pull from the following tree:

 git://git.infradead.org/users/pcmoore/lblnet-2.6

Thanks.

---

Manish Katiyar (1):
      netlabel: Fix compilation warnings in net/netlabel/netlabel_addrlist.c

Paul Moore (1):
      netlabel: Fix compiler warnings in netlabel_mgmt.c

roel kluin (1):
      cipso: unsigned buf_len cannot be negative


 net/ipv4/cipso_ipv4.c            |    7 ++++---
 net/netlabel/netlabel_addrlist.c |    2 ++
 net/netlabel/netlabel_addrlist.h |   22 ++++++++++++++++++++++
 net/netlabel/netlabel_mgmt.c     |    2 +-
 4 files changed, 29 insertions(+), 4 deletions(-)


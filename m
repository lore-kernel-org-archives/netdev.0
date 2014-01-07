From: valentina.giusti@bmw-carit.de
Subject: [PATCH 0/2] libnetfilter_queue: add support for UID/GID socket info
Date: Tue,  7 Jan 2014 14:30:18 +0100
Message-ID: <1389101420-16557-1-git-send-email-valentina.giusti@bmw-carit.de>
References: <20131221113804.GA17964@localhost>
Cc: netdev@vger.kernel.org, fw@strlen.de, daniel.wagner@bmw-carit.de
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:51403 "EHLO
	linuxmail.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750910AbaAGNaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 08:30:25 -0500
In-Reply-To: <20131221113804.GA17964@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentina Giusti <Valentina.Giusti@bmw-carit.de>

This patchset contains the following changes:
* re-implemented nfq_get_uid and nfq_get_gid as suggested by Pablo Neira Ayuso
* corrected enum nfqnl_attr_type in linux_nfnetlink_queue.h
* added a test for the aforementioned new APIs in utils/nfqnl_test.c

Best Regards,

Valentina Giusti (2):
  src: add support for UID/GID socket info
  utils: add test for nfq_get_uid and nfq_get_gid

 include/libnetfilter_queue/libnetfilter_queue.h    |  4 ++
 include/libnetfilter_queue/linux_nfnetlink_queue.h |  6 ++-
 include/linux/netfilter/nfnetlink_queue.h          |  6 ++-
 src/libnetfilter_queue.c                           | 60 ++++++++++++++++++++++
 src/nlmsg.c                                        |  2 +
 utils/nfqnl_test.c                                 | 14 ++++-
 6 files changed, 89 insertions(+), 3 deletions(-)

-- 
1.8.5.1

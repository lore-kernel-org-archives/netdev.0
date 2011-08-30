From: kaber@trash.net
Subject: [PATCH 0/8] netfilter: netfilter fixes
Date: Tue, 30 Aug 2011 16:41:13 +0200
Message-ID: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153Ab1H3Ol0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are a couple of netfilter fixes:

- invalid return values in xt_rateest_mt_checkentry(), from Eric

- a possible memory leak in ip_queue and ip6_queue, from Jesper Juhl

- an incorrect Kconfig dependency for ebtables, from Bart

- handling of (bogus) NF_STOLEN verdicts in userspace queueing, from Florian

- a fix for missing address translation in certain cases for NATed PPTP
  connections, from Sanket Shah

- possible out-of-bounds memory access in TCP connection tracking in case
  of partial TCP options, from Jozsef

- an incorrect multiplication of TCPOLEN_TSTAMP_ALIGNED in the fast-path
  check of TCP connection tracking, from Jozsef

- update of the netfilter git tree URLs to a directory shared by Pablo and
  myself (trees will move after patch is applied)

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

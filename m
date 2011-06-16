From: kaber@trash.net
Subject: [PATCH 0/8] netfilter: netfilter fixes for -rc1
Date: Thu, 16 Jun 2011 21:41:35 +0200
Message-ID: <1308253301-29894-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64067 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757823Ab1FPTlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:41:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches fix a couple of netfilter bugs:

- an IPVS/netns shutdown related crash in conntrack, from Hans

- avoidance of double sequence number adjustment on loopback with
  NAT to fix data corruption issues, from Julian

- a fix for the protocol check in the ECN match: in addition to the
  protocol it needs to check for inversion, from myself

- a fix for missing inversion in the ECN IP header matching, from
  myself

- a compile for for ip_tables with debugging enabled, from
  Sebastian Andrzej Siewior

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

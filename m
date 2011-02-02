From: kaber@trash.net
Subject: [PATCH 0/4] netfilter: netfilter fixes
Date: Thu,  3 Feb 2011 00:45:26 +0100
Message-ID: <1296690330-9887-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45199 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab1BBXpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:45:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are a couple of netfilter fixes for 2.6.38, containing:

- a missing conntrack reference count increment during ctnetlink table
  dumping, leading to a crash, from Pablo

- a fix for mismatches in the IPv6 iprange match, from Thomas Jacob

- a fix to make arp_tables mangling work again after some cleanups,
  from Pablo

- a fix for missing information in ctnetlink when events are filtered
  using the CT target, from Pablo

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

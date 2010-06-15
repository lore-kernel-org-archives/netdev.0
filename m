From: kaber@trash.net
Subject: [PATCH 00/17] netfilter: netfilter update
Date: Tue, 15 Jun 2010 17:38:26 +0200
Message-ID: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631Ab0FOP3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

following is a first netfilter update for net-next, containing:

- RCU conversions for nfnetlink_log, nfnetlink_queue, ip_queue, ip6_queue
  and ipt_CLUSTERIP from Eric

- conversion of the untracked conntrack structure to per-cpu data, from Eric

- removal of the nth_lock spinlock, from Eric

- conversion of bridge netfilter to skb_set_noref, from Eric

- a new IDLETIMER target, which can be used to trigger sysfs notifications
  when a certain xtables rule hasn't been hit for a specific time, from
  Luciano Coelho

- removal of some atomic ops in netfilter IPv6 defragmentation, from Shan Wei

- minor cleanups in xt_sctp and the netfilter checksumming function, from
  Shan Wei

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

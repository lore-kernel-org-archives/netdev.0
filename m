From: kaber@trash.net
Subject: [PATCH 0/2] netfilter: netfilter fixes for 2.6.38
Date: Sat, 19 Feb 2011 16:41:03 +0100
Message-ID: <1298130065-14205-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33904 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728Ab1BSPlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 10:41:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches for two netfilter bugs:

- an oops in nfnetlink_log in combination with TPROXY when a socket
  in TIME-WAIT state is assigned to skb->sk, patch from Florian Westphal

- incorrect printing of the MAC header in the ip6t_LOG target,
  from Joerg Marx

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


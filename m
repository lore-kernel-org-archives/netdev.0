From: kaber@trash.net
Subject: [PATCH 0/4] netfilter: netfilter fixes
Date: Sun, 20 Mar 2011 16:32:24 +0100
Message-ID: <1300635148-22648-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1CTPcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 11:32:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches fix a couple of netfilter bugs:

- a bug in ipset which caused the hash:port set types to silently
  ignore address ranges when non-TCP/UDP entries were added, from
  Jozsef

- a missing check for set type revision in ipset, from Jozsef

- a fix for iptables reentrancy, from Eric

- a fix for a buffer overflow in the ipt_CLUSTERIP proc handler,
  from Vasiliy Kulikov

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

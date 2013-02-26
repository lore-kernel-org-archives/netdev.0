From: pablo@netfilter.org
Subject: [PATCH 0/2] netfilter fixes for net
Date: Tue, 26 Feb 2013 14:45:18 +0100
Message-ID: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:25313 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3BZNpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 08:45:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains two bugfixes for netfilter/ipset via
Jozsef Kadlecsik, they are:

* Fix timeout corruption if sets are resized, by Josh Hunt.

* Fix bogus error report if the flag nomatch is set, from Jozsef.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Josh Hunt (1):
  netfilter: ipset: timeout values corrupted on set resize

Jozsef Kadlecsik (1):
  netfilter: ipset: "Directory not empty" error message

 include/linux/netfilter/ipset/ip_set_ahash.h |    4 +++-
 net/netfilter/ipset/ip_set_core.c            |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

-- 
1.7.10.4

From: pablo@netfilter.org
Subject: [PATCH 0/2] ipvs fixes for 3.5
Date: Tue, 17 Jul 2012 12:06:27 +0200
Message-ID: <1342519589-3348-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48085 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab2GQKHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:07:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

I know that we're in fairly late stage to request pulls, but the IPVS people
pinged me with little patches with oops fixes last week.

One of them was recently introduced (during the 3.4 development cycle) while
cleaning up the IPVS netns support. They are:

* Fix one regression introduced in 3.4 while cleaning up the
  netns support for IPVS, from Julian Anastasov.

* Fix one oops triggered due to resetting the conntrack attached to the skb
  instead of just putting it in the forward hook, from Lin Ming. This problem
  seems to be there since 2.6.37 according to Simon Horman.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Julian Anastasov (1):
  ipvs: fix oops in ip_vs_dst_event on rmmod

Lin Ming (1):
  ipvs: fix oops on NAT reply in br_nf context

 include/net/ip_vs.h            |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

--
1.7.10

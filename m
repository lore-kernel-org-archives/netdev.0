From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] ipv6:export nd_tbl
Date: Tue,  6 Dec 2011 14:52:41 +0800
Message-ID: <a46bd31bb9a4876e97f96e82d399a26506646d04.1323154266.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[IPv4/...),
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> (maintainer:NETWORKING
	[IPv4/...),
	James Morris <jmorris@namei.org> (maintainer:NETWORKING [IPv4/...),
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> (maintainer:NETWORKING
	[IPv4/...),
	Patrick McHardy <kaber@trash.net> (maintainer:NETWORKING [IPv4/...),
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:48490 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab1LFGuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 01:50:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A customer wants to use nd_tbl in his kernel module,
the easiest way is to export nd_tbl, just as arp_tbl.

There were some requests to export nd_tbl, like:
http://marc.info/?l=netfilter-devel&m=111416950824614&w=2
http://marc.info/?l=linux-netdev&m=110715893206991&w=2

But they were all rejected.
I want to know the reason why can't nd_tbl be exported just as arp_tbl,
and how can we look up nd_tbl without exporting it.

thanks
Weiping Pan

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv6/ndisc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0cb78d7..1ab98b5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -153,6 +153,7 @@ struct neigh_table nd_tbl = {
 	.gc_thresh2 =	 512,
 	.gc_thresh3 =	1024,
 };
+EXPORT_SYMBOL(nd_tbl);
 
 /* ND options */
 struct ndisc_options {
-- 
1.7.4.4

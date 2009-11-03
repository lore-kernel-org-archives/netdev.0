From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Support specifying the network namespace upon device
 creation.
Date: Tue, 03 Nov 2009 11:16:59 +0100
Message-ID: <4AF0031B.4060708@gmail.com>
References: <m1eioggeux.fsf@fess.ebiederm.org>	<4AEFF7BB.4090301@gmail.com>	<m1ws28ey3k.fsf@fess.ebiederm.org> <20091103.020555.156050455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57084 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbZKCKRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:17:25 -0500
In-Reply-To: <20091103.020555.156050455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

> It can also be argued that for functions, wrapping the args is
> worse because it makes grep output less useful.  In fact that's,
> I believe, Linus's most recent recommendation in this area :)

Yes, true.

One thing I usually miss is the { next to "struct some_name" declaratio=
ns,
to ease games based on "grep"=20

Would you accept one boring cleanup patch in include/net like following=
 ?

diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..1524b75 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -49,8 +49,7 @@
=20
 struct fib_nh;
 struct inet_peer;
-struct rtable
-{
+struct rtable {
 	union
 	{
 		struct dst_entry	dst;
@@ -77,16 +76,14 @@ struct rtable
 	struct inet_peer	*peer; /* long-living peer info */
 };
=20
-struct ip_rt_acct
-{
+struct ip_rt_acct {
 	__u32 	o_bytes;
 	__u32 	o_packets;
 	__u32 	i_bytes;
 	__u32 	i_packets;
 };
=20
-struct rt_cache_stat=20
-{
+struct rt_cache_stat {
         unsigned int in_hit;
         unsigned int in_slow_tot;
         unsigned int in_slow_mc;

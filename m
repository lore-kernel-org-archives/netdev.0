From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: unregister_netdevice 2.6.9
Date: Wed, 20 Oct 2004 15:40:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020.154045.128392519.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Oct_20_15:40:45_2004_629)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: lukasz@trabinski.net
In-Reply-To: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Wed_Oct_20_15:40:45_2004_629)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

In article <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl> (at Tue, 19 Oct 2004 17:58:58 +0200 (CEST)), Lukasz Trabinski <lukasz@trabinski.net> says:

> After shutdown/reboot :
> 
> unregister_netdevice: waiting for xxxx to become free. Usage count = 1
> 
> and still wait.

Does this fix your problem?

----Next_Part(Wed_Oct_20_15:40:45_2004_629)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Return-Path: <netdev-bounce@oss.sgi.com>
Delivered-To: yoshfuji@yue.st-paulia.net
Received: from sapphire.st-paulia.net (sapphire.linux-ipv6.org [203.178.140.14])
	by yue.st-paulia.net (Postfix) with ESMTP id 823DC33CE5
	for <yoshfuji@yue.st-paulia.net>; Wed, 20 Oct 2004 15:37:38 +0900 (JST)
Received: by sapphire.st-paulia.net (Postfix)
	id 1692923CF9; Wed, 20 Oct 2004 15:57:29 +0900 (JST)
Delivered-To: yoshfuji@sapphire.st-paulia.net
Received: from nezu.linux-ipv6.org (linux6.nezu.wide.ad.jp [203.178.142.218])
	by sapphire.st-paulia.net (Postfix) with ESMTP id 164B223CF8
	for <yoshfuji@sapphire.st-paulia.net>; Wed, 20 Oct 2004 15:57:26 +0900 (JST)
Received: from oss.sgi.com (oss.sgi.com [192.48.159.27])
	by nezu.linux-ipv6.org (8.13.1/8.13.1/Debian-13) with ESMTP id i9K6arBC014211
	for <yoshfuji@linux-ipv6.org>; Wed, 20 Oct 2004 15:36:53 +0900
Received: from oss.sgi.com (localhost [127.0.0.1])
	by oss.sgi.com (8.13.0/8.13.0) with ESMTP id i9K6b4gC027433;
	Tue, 19 Oct 2004 23:37:04 -0700
Received: with ECARTIS (v1.0.0; list netdev); Tue, 19 Oct 2004 23:35:31 -0700 (PDT)
Received: from yue.st-paulia.net (yue.linux-ipv6.org [203.178.140.15])
	by oss.sgi.com (8.13.0/8.13.0) with ESMTP id i9K6ZPF4027130
	for <netdev@oss.sgi.com>; Tue, 19 Oct 2004 23:35:26 -0700
Received: from localhost (localhost [127.0.0.1])
	by yue.st-paulia.net (Postfix) with ESMTP
	id 07FF133CE5; Wed, 20 Oct 2004 15:35:52 +0900 (JST)
Date: Wed, 20 Oct 2004 15:35:25 +0900 (JST)
Message-Id: <20041020.153525.50629727.yoshfuji@linux-ipv6.org>
To: kaber@trash.net, davem@davemloft.net
Cc: netdev@oss.sgi.com
Subject: Re: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in
 ip6_route_add error paths
From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <417591A2.4090201@trash.net>
References: <417591A2.4090201@trash.net>
Organization: USAGI Project
X-URL: http://www.yoshifuji.org/%7Ehideaki/
X-Fingerprint: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
X-PGP-Key-URL: http://www.yoshifuji.org/%7Ehideaki/hideaki@yoshifuji.org.asc
X-Face: "5$Al-.M>NJ%a'@hhZdQm:."qn~PA^gq4o*>iCFToq*bAi#4FRtx}enhuQKz7fNqQz\BYU]
 $~O_5m-9'}MIs`XGwIEscw;e5b>n"B_?j/AkL~i/MEa<!5P`&C$@oP>ZBLP
X-Mailer: Mew version 2.2 on Emacs 20.7 / Mule 4.1 (AOI)
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Oct_20_15:35:25_2004_849)--"
Content-Transfer-Encoding: 7bit
X-archive-position: 10503
X-ecartis-version: Ecartis v1.0.0
Sender: netdev-bounce@oss.sgi.com
Errors-To: netdev-bounce@oss.sgi.com
X-original-sender: yoshfuji@linux-ipv6.org
Precedence: bulk
X-list: netdev

----Next_Part(Wed_Oct_20_15:35:25_2004_849)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

In article <417591A2.4090201@trash.net> (at Wed, 20 Oct 2004 00:13:54 +0200), Patrick McHardy <kaber@trash.net> says:

> The recent changes to ip6_route_add added multiple leaks in
> error paths. This patch should fix them.

Agreed. David, please apply.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji

----Next_Part(Wed_Oct_20_15:35:25_2004_849)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Return-Path: <kaber@trash.net>
Delivered-To: yoshfuji@yue.st-paulia.net
Received: from sapphire.st-paulia.net (sapphire.linux-ipv6.org [203.178.140.14])
	by yue.st-paulia.net (Postfix) with ESMTP id 64A1433CE5
	for <yoshfuji@yue.st-paulia.net>; Wed, 20 Oct 2004 07:15:11 +0900 (JST)
Received: by sapphire.st-paulia.net (Postfix)
	id 5B3A223CF9; Wed, 20 Oct 2004 07:34:58 +0900 (JST)
Delivered-To: yoshfuji@sapphire.st-paulia.net
Received: from nezu.linux-ipv6.org (linux6.nezu.wide.ad.jp [203.178.142.218])
	by sapphire.st-paulia.net (Postfix) with ESMTP id 703B023CF8
	for <yoshfuji@sapphire.st-paulia.net>; Wed, 20 Oct 2004 07:34:55 +0900 (JST)
Received: from gw.localnet ([62.206.217.67])
	by nezu.linux-ipv6.org (8.13.1/8.13.1/Debian-13) with ESMTP id i9JMEMii001727
	for <yoshfuji@linux-ipv6.org>; Wed, 20 Oct 2004 07:14:25 +0900
Received: from [172.16.1.123] (helo=trash.net ident=kaber)
	by gw.localnet with esmtp (Exim 3.36 #1 (Debian))
	id 1CK2Ma-0002us-00; Wed, 20 Oct 2004 00:21:52 +0200
Message-ID: <417591A2.4090201@trash.net>
Date: Wed, 20 Oct 2004 00:13:54 +0200
From: Patrick McHardy <kaber@trash.net>
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040413 Debian/1.6-5
X-Accept-Language: en
MIME-Version: 1.0
To: "David S. Miller" <davem@redhat.com>
Cc: netdev@oss.sgi.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in ip6_route_add
 error paths
Content-Type: multipart/mixed;
 boundary="------------040705080908040609060609"

This is a multi-part message in MIME format.
--------------040705080908040609060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The recent changes to ip6_route_add added multiple leaks in
error paths. This patch should fix them.

Regards
Patrick


--------------040705080908040609060609
Content-Type: text/plain;
 name="p2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p2"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 23:46:56+02:00 kaber@coreworks.de 
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/route.c
#   2004/10/19 23:46:17+02:00 kaber@coreworks.de +8 -3
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
+++ b/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
@@ -798,8 +798,10 @@
 
 	rt = ip6_dst_alloc();
 
-	if (rt == NULL)
-		return -ENOMEM;
+	if (rt == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
 
 	rt->u.dst.obsolete = -1;
 	rt->rt6i_expires = clock_t_to_jiffies(rtmsg->rtmsg_info);
@@ -962,7 +964,10 @@
 out:
 	if (dev)
 		dev_put(dev);
-	dst_free((struct dst_entry *) rt);
+	if (idev)
+		in6_dev_put(idev);
+	if (rt)
+		dst_free((struct dst_entry *) rt);
 	return err;
 }
 

--------------040705080908040609060609--

----Next_Part(Wed_Oct_20_15:35:25_2004_849)----


----Next_Part(Wed_Oct_20_15:40:45_2004_629)----

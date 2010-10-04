From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Mon, 04 Oct 2010 17:21:50 +0200
Message-ID: <1286205710.18293.309.camel@edumazet-laptop>
References: <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101003094221.GA2028@del.dom.local>
	 <1286181729.18293.8.camel@edumazet-laptop>
	 <20101004120626.GA2022@del.dom.local>
	 <1286196720.18293.196.camel@edumazet-laptop>
	 <20101004142415.GA2049@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53742 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0JDPV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 11:21:56 -0400
Received: by fxm3 with SMTP id 3so33084fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 08:21:55 -0700 (PDT)
In-Reply-To: <20101004142415.GA2049@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 octobre 2010 =C3=A0 16:24 +0200, Jarek Poplawski a =C3=A9cr=
it :

> You are right! There is no other lock. (I forgot I removed
> qdisc_list_lock already ;-)
>=20
> Sorry,

No problem, better to ask before inclusion anyway ;)

About checkpatch, patch is fine (checkpatch.pl shouts because of yet
unknown __rcu marker, I believe someone submitted a patch for this [and
__percpu] weeks ago, but lkml people seem very slow these days)

ERROR: need consistent spacing around '*' (ctx:WxV)
#10: FILE: include/linux/netdevice.h:989:
+	struct netdev_queue __rcu *ingress_queue;
 	                          ^
diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 2039acd..25d3842 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -143,7 +143,9 @@ our $Sparse	=3D qr{
 			__must_check|
 			__init_refok|
 			__kprobes|
-			__ref
+			__ref|
+			__percpu|
+			__rcu
 		}x;
=20
 # Notes to $Attribute:



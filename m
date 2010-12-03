From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 0/3] bonding: add the debugfs interface to see RLB hash
 table
Date: Fri, 03 Dec 2010 16:19:28 +0900
Message-ID: <4CF89A00.8030902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:44057 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab0LCHTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 02:19:40 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB37JcHJ022554
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 3 Dec 2010 16:19:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20E4445DE67
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:19:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0780D45DE55
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:19:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED1CE1DB803F
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:19:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4CF31DB8040
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:19:37 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

Thank you for your quick review. I update my patchset according to your comment.
But I didn't take measures against your concern about seq_file. If I come up with
a good idea, I'll correct it.

--
This patchset provides the debugfs facility to the bonding driver and
the interface to see RLB hashtable in it.

 *[PATCH 1/3] bonding: add the debugfs facility to the bonding driver
 *[PATCH 2/3] bonding: migrate some macros from bond_alb.c to bond_alb.h
 *[PATCH 3/3] bonding: add the debugfs interface to see RLB hash table

Best regards,
Taku Izumi


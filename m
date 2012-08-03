From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: RFC3484: default address selection malfunctioning
Date: Fri, 3 Aug 2012 07:35:06 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017E35B1@HKNPRD0410MB350.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:21979
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750843Ab2HCHfP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 03:35:15 -0400
Received: from mail51-db3 (localhost [127.0.0.1])	by mail51-db3-R.bigfish.com
 (Postfix) with ESMTP id D16484A018D	for <netdev@vger.kernel.org>; Fri,  3 Aug
 2012 07:35:13 +0000 (UTC)
Received: from DB3EHSMHS007.bigfish.com (unknown [10.3.81.243])	by
 mail51-db3.bigfish.com (Postfix) with ESMTP id C8E90260048	for
 <netdev@vger.kernel.org>; Fri,  3 Aug 2012 07:35:12 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
      In Default address selction, From DNS query, the destination addresses are both a site local and a link scope addresses. the source addresses a site local address and a global address. So while pinging to the host(with name) according to RFC3484, the kernel should select the link local destination address and link local source address right? But linux kernel-3.0.26 is using the global address as source address and site local as destination address.

Why? is it a bug? And the DNS server address is a site local address. Had a default router with link local address

Thank you.

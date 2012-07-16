From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: where timer expiry check is happening before sending ICMP_REPLY in
 ipv6
Date: Mon, 16 Jul 2012 13:41:10 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DBB97@SIXPRD0410MB359.apcprd04.prod.outlook.com>
References: <4A71D24947E78D43BC584A7CD4391A41017DBB44@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<4A71D24947E78D43BC584A7CD4391A41017DBB86@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:58499
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103Ab2GPNlf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 09:41:35 -0400
Received: from mail88-va3 (localhost [127.0.0.1])	by mail88-va3-R.bigfish.com
 (Postfix) with ESMTP id E16664400F6	for <netdev@vger.kernel.org>; Mon, 16 Jul
 2012 13:41:34 +0000 (UTC)
Received: from VA3EHSMHS032.bigfish.com (unknown [10.7.14.244])	by
 mail88-va3.bigfish.com (Postfix) with ESMTP id 9364C3A00B7	for
 <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:41:33 +0000 (UTC)
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DBB86@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,
In kernel-3.0.26 code net/ipv6/icmp.c, while sending ICMP reply where it checks for the timer expiry. It should check the value given by a router advertisement. I think the expiry value is stored in
rt->rt6_expires in ndisc.c (line no: 1284). Then while sending an ICMP reply, it should check with the expiry timer right? Where that check is happening? Please somebody explain me.

Thank you. 

--Regards,
K.Balakumaran

From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: timer expiry check at icmp.c in ipv6
Date: Mon, 16 Jul 2012 13:44:44 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DBBAF@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:51452
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753403Ab2GPNou convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 09:44:50 -0400
Received: from mail216-ch1 (localhost [127.0.0.1])	by
 mail216-ch1-R.bigfish.com (Postfix) with ESMTP id 758772600A1	for
 <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:44:49 +0000 (UTC)
Received: from CH1EHSMHS013.bigfish.com (snatpool2.int.messaging.microsoft.com
 [10.43.68.232])	by mail216-ch1.bigfish.com (Postfix) with ESMTP id DEC00A0048
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:44:47 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear all,

In kernel-3.0.26 code net/ipv6/icmp.c, while sending ICMP reply where it checks for the timer expiry. It should check the value given by a router advertisement. I think the expiry value is stored in rt->rt6_expires in ndisc.c (line no: 1284). Then while sending an ICMP reply, it should check with the expiry timer right? Where that check is happening? Please somebody explain me.

Thank you.

--Regards,
K.Balakumaran

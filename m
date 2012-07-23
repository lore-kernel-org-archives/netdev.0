From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: RE: flush cache according to 'preferred life time'
Date: Mon, 23 Jul 2012 08:36:03 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DE4FB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
References: <4A71D24947E78D43BC584A7CD4391A41017DE48F@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<500D05D6.7090108@cn.fujitsu.com>
 <4A71D24947E78D43BC584A7CD4391A41017DE4C1@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<500D0A24.6060200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:4104
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458Ab2GWIgL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 04:36:11 -0400
In-Reply-To: <500D0A24.6060200@cn.fujitsu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Than you Gao-san. Your patch is helpful. I will try that. Also I am facing another problem. Tahi test case section nd test case 145 is failing if gc_interval is 30. The test case is as follows
 * The tester node (tn) sends RA with curhoplimit 64
 * tn sends a ICMP_REQUEST and checks the ICMP_REPLY from nut is having hoplimit 64. (it is fine in my case)
 * Then the tn sends a RA with curhoplimit 0. (It should be ignored)
 * Then again tn sends ICMP_REQUEST and checks the ICMP_REPLY from nut whether the hoplimit remains 64 (but it changes to 255 if cache is present. But once I changed the gc_interval to 1, this testcase passes)
Can you please explain what is the reason. 

Thank you

--Regards,
K.Balakumaran

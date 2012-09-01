From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH net-next 0/12] qlcnic: patches for new adapter - Qlogic
 83XX CNA
Date: Fri, 31 Aug 2012 18:29:42 -0700
Message-ID: <A26832265F3C994CBA2F7DA55BFAE70E74A06414B8@AVEXMB2.qlogic.org>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
	<20120831.200035.576516635394055754.davem@davemloft.net>
 <20120831.205308.538476490984218378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:36205
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755332Ab2IAB3w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 21:29:52 -0400
In-Reply-To: <20120831.205308.538476490984218378.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry about that. I will address all the issues in the next set of patches.
I am waiting for feedback from others as well.

Thanks,
Sony

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Friday, August 31, 2012 5:53 PM
To: Sony Chacko
Cc: netdev; Dept-NX Linux NIC Driver
Subject: Re: [PATCH net-next 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA

From: David Miller <davem@davemloft.net>
Date: Fri, 31 Aug 2012 20:00:35 -0400 (EDT)

> From: Sony Chacko <sony.chacko@qlogic.com>
> Date: Fri, 31 Aug 2012 18:36:47 -0400
>
>> Please apply the updated patch series to net-next.
>
> You posted too soon, you received other feedback in the mean-time
> which you should address as well.

Also in patch #5:

-               qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
+               qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+                                                QLCNIC_IP_UP);

This is not the correct way to format multi-line function calls, the correct way is:

                qlcnic_config_ipaddr(adapter, ifa->ifa_address,
                                     QLCNIC_IP_UP);

That is, you line up the first character of the argument to the column right after the openning parenthesis on the pevious line, using the appropriate number of TAB and SPACE characters necessary to achieve that.


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

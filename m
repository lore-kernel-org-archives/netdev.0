From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 05/12] bna: Enable Multi Buffer RX
Date: Thu, 12 Dec 2013 08:04:14 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B69010DD81@HQ1-EXCH01.corp.brocade.com>
References: <1386745251-13710-1-git-send-email-rmody@brocade.com>
	<1386745251-13710-6-git-send-email-rmody@brocade.com>
 <20131211.122718.1401456146385583996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:26746 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab3LLQDY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 11:03:24 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rBCFlFOA007072
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 08:03:24 -0800
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1gpwn39188-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 08:03:24 -0800
In-Reply-To: <20131211.122718.1401456146385583996.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, December 11, 2013 9:27 AM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Tue, 10 Dec 2013 23:00:44 -0800
>
>> Using module parameter bnad_multi_buffer_rx this behavior can be
>reverted.
>
>Sorry, I've told you guys a thousand times to use generic configuration
>mechanisms, such as ethtool, to control behavior rather than module
>parameters.
>
>If the generic facility you need doesn't exist, make it, don't do you own
>custom thing.

We'll remove the module parameter to disable multi-buffer RX feature
and keep it enabled by default.

We'll add such a control in future when generic facility becomes available.

Thanks
Rasesh

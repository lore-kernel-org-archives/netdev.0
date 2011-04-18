From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 1/2] bna: fix for clean fw re-initialization
Date: Mon, 18 Apr 2011 12:26:12 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A5D7348A7B@HQ1-EXCH01.corp.brocade.com>
References: <1302804319-15677-1-git-send-email-rmody@brocade.com>
 <20110414.133957.226775217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Debashis Dutt <ddutt@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:50102 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751556Ab1DRUGp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 16:06:45 -0400
In-Reply-To: <20110414.133957.226775217.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of David Miller
>Sent: Thursday, April 14, 2011 1:40 PM
>To: Rasesh Mody
>Cc: netdev@vger.kernel.org; Debashis Dutt
>Subject: Re: [PATCH 1/2] bna: fix for clean fw re-initialization
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Thu, 14 Apr 2011 11:05:18 -0700
>
>> During a kernel crash, bna control path state machine and firmware do
>not
>> get a notification and hence are not cleanly shutdown. The registers
>> holding driver/IOC state information are not reset back to valid
>> disabled/parking values. This causes subsequent driver initialization
>> to hang during kdump kernel boot. This patch, during the
>initialization
>> of first PCI function, resets corresponding register when unclean
>shutown
>> is detect by reading chip registers. This will make sure that ioc/fw
>> gets clean re-initialization.
>>
>> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>
>Applied.

Hello David,

We were not able to see these patches when we did a git-pull of 
net-next-2.6. We were wondering if the patches are stuck behind
others and not committed to the tree.

Thanks.

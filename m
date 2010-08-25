From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next-2.6 1/1]: bna: Fix build break for allyesconfig
Date: Wed, 25 Aug 2010 16:05:43 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A4AE226112@HQ1-EXCH01.corp.brocade.com>
References: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
 <20100825.152243.260093985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Akshay Mathur <amathur@brocade.com>,
	Debashis Dutt <ddutt@Brocade.COM>,
	Jing Huang <huangj@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55531 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751933Ab0HYXFt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 19:05:49 -0400
In-Reply-To: <20100825.152243.260093985.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller <mailto:davem@davemloft.net>
>Sent: Wednesday, August 25, 2010 3:23 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Wed, 25 Aug 2010 14:32:10 -0700
>
>> From: Rasesh Mody <rmody@brocade.com>
>> 
>> This patch contains a fix for the build break caused by multiple
>> definitions of symbols between Brocade's FC/FCOE driver(BFA) 
>> and 10G Networking Driver(BNA).
>> 
>> The fix is to make BNA a module only driver.
>> 
>> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>
>You have to be kidding me.  This fix is totally unacceptable.
>
>You have to go through your two drivers and:
>
>1) Mark as 'static' symbols that don't actually need global
>   visibility.
>
>2) Make the two drivers use unique namespaces for the function
>   names that must be globally visible for whatever reason.
>
>You are really trying my patience, fix this properly and promptly
>or I'm removing your driver from the tree.

David,

We are working on fixing it properly. We will submit the patches as soon as possible.

Thanks,
Rasesh

From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH net 2/3] qlcnic: Fix resource allocation for TX queues
Date: Fri, 3 Jan 2014 06:57:34 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B938CF8D0B6@avmb3.qlogic.org>
References: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
	<1388687925-17882-3-git-send-email-manish.chopra@qlogic.com>
 <20140102.171958.2254381067633302234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19490 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750907AbaACG5k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 01:57:40 -0500
In-Reply-To: <20140102.171958.2254381067633302234.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of David Miller
>Sent: Friday, January 03, 2014 3:50 AM
>To: Manish Chopra
>Cc: netdev; Rajesh Borundia; Dept-NX Linux NIC Driver
>Subject: Re: [PATCH net 2/3] qlcnic: Fix resource allocation for TX queues
>
>From: Manish Chopra <manish.chopra@qlogic.com>
>Date: Thu, 2 Jan 2014 13:38:44 -0500
>
>> o TX queues allocation was getting distributed equally among all the
>>   functions of the port including VFs and PF. Which was leading to failure
>>   in PF's multiple TX queues creation.
>>
>> o Instead of dividing queues equally allocate one TX queue for each VF as VF
>>   doesn't support multiple TX queues.
>>
>> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
>
>Applied.
>
>I did not see the third patch.
>--

Yes David. Somehow it didn't go to netdev. I will send third patch as a separate patch

Thank you 

From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 05 Dec 2011 09:05:23 +0800
Message-ID: <4EDC18D3.4060900@linux.vnet.ibm.com>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com> <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com> <20111203.222659.277419094309941060.davem@davemloft.net> <1322983717.24828.8.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:41732 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881Ab1LEBFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 20:05:32 -0500
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Mon, 5 Dec 2011 06:35:30 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB515Q9k3690708
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 06:35:26 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB515PsV015677
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 12:05:26 +1100
In-Reply-To: <1322983717.24828.8.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2011 03:28 PM, Jeff Kirsher wrote:

> On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Sat,  3 Dec 2011 03:44:26 -0800
>>
>>> +	if ((!adapter->tx_hang_recheck) &&
>>
>> Excessive parenthesis, please remove.
>>
>>> +		adapter->tx_hang_recheck = 1;
>>
>> This variable is a bool, set it to true or false.
>>
>>> +			adapter->tx_hang_recheck = 0;
>>
>> Likewise.
>>
>>> +	adapter->tx_hang_recheck = 0;
>>
>> Likewise.
> 
> Michael/Flavio -
> 
> To expedite this patch, I can make the changes that Dave is requesting
> and re-submit v2 of the patch, if that is ok with you.
> 

Hi, Jeff

That's ok for me, I think it's good if you can work with Dave and make
out a final version for us, if you want my help, please mail me at any
time, I'm glad to work with you.

Flavio:
What's your opinion?

Thanks,
Michael Wang

> -Jeff

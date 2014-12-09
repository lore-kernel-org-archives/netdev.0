From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 0/4] net: allow setting congctl via routing
 table
Date: Tue, 09 Dec 2014 22:22:02 +0100
Message-ID: <548767FA.2020402@redhat.com>
References: <1417909163-19135-1-git-send-email-dborkman@redhat.com> <20141209.155844.1175199719902606020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbaLIVWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:22:13 -0500
In-Reply-To: <20141209.155844.1175199719902606020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2014 09:58 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Sun,  7 Dec 2014 00:39:19 +0100
>
>> This is the second part of our work and allows for setting the congestion
>> control algorithm via routing table. For details, please see individual
>> patches.
>>
>> Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.
>>
>> Patch for iproute2: http://patchwork.ozlabs.org/patch/418149/
>>
>> Thanks!
>>
>> v1->v2:
>>   - Very sorry, I noticed I had decnet disabled during testing.
>>     Added missing header include in decnet, rest as is.
>
> I don't like how you have to explicitly load the congestion control
> module before asking for it to be used in the route entry metric.
>
> It should request the module automatically just like the stack already
> does for other cases.

Ok, sure, adding auto-loading should not be a problem. Will respin
with that tomorrow.

Thanks.

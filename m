From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Wed, 06 Aug 2014 12:12:33 +0200
Message-ID: <53E1FF91.8040200@redhat.com>
References: <1406837476-13776-1-git-send-email-dborkman@redhat.com> <20140731.222804.1403723639172562683.davem@davemloft.net> <53DF56F1.4020701@redhat.com> <20140804.114146.2155043446693665715.davem@davemloft.net> <53E0F544.4020504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	akinobu.mita@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806AbaHFKMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 06:12:41 -0400
In-Reply-To: <53E0F544.4020504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2014 05:16 PM, Daniel Borkmann wrote:
> On 08/04/2014 08:41 PM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Mon, 04 Aug 2014 11:48:33 +0200
>>
>>> Akinobu and I also tested this patch with the above fix included,
>>> and it runs through the 3 relevant test cases _without_ any errors
>>> on the nandsim device (simulator for MTD devs):
>>
>> On one endianness only perhaps?
>
> On x86_64, ppc64, ARM (i.MX28, i.MX53 and i.MX6).

Not really urgent, so if there are no further objections,
I'd respin it with the code fix included, proper Tested-by
tags from MTD people, and updated commit message when
net-next reopens again.

Thanks,

Daniel

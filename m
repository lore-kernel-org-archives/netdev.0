From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Wed, 06 Aug 2014 12:19:37 -0700 (PDT)
Message-ID: <20140806.121937.2015268617742451981.davem@davemloft.net>
References: <20140804.114146.2155043446693665715.davem@davemloft.net>
	<53E0F544.4020504@redhat.com>
	<53E1FF91.8040200@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	akinobu.mita@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbaHFTTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 15:19:40 -0400
In-Reply-To: <53E1FF91.8040200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 06 Aug 2014 12:12:33 +0200

> On 08/05/2014 05:16 PM, Daniel Borkmann wrote:
>> On 08/04/2014 08:41 PM, David Miller wrote:
>>> From: Daniel Borkmann <dborkman@redhat.com>
>>> Date: Mon, 04 Aug 2014 11:48:33 +0200
>>>
>>>> Akinobu and I also tested this patch with the above fix included,
>>>> and it runs through the 3 relevant test cases _without_ any errors
>>>> on the nandsim device (simulator for MTD devs):
>>>
>>> On one endianness only perhaps?
>>
>> On x86_64, ppc64, ARM (i.MX28, i.MX53 and i.MX6).
> 
> Not really urgent, so if there are no further objections,
> I'd respin it with the code fix included, proper Tested-by
> tags from MTD people, and updated commit message when
> net-next reopens again.

Ok, please do.

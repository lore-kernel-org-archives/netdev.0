From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 28 Nov 2007 10:17:30 +0100
Message-ID: <474D322A.9090207@trash.net>
References: <474B0D5D.2090506@trash.net>	<20071127.200803.24564635.takano@axe-inc.co.jp>	<474C0AA2.5040900@trash.net> <20071128.161905.109761213.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	dada1@cosmosbay.com, t.kudoh@aist.go.jp
To: Ryousei Takano <takano-ryousei@aist.go.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41260 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbXK1JRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 04:17:37 -0500
In-Reply-To: <20071128.161905.109761213.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ryousei Takano wrote:
> Hi Patrick,
> 
>>>>> +struct tc_psp_qopt
>>>>> +{
>>>>> +	__u32	defcls;
>>>>> +	__u32	rate;
>>>>> +};
>>>> What unit is rate measured in?
>>>>
>>> 'rate' is the transmission rate in bytes per sec.
>>
>> So wouldn't it make sense to use u64 then for 10GBit networks?
>>
> I decided to use u32 after tc_ratespec.rate is u32.
> u32 is large enough for 10Gbit networks, but small for 40Gbit.
> I will use u64, because code becomes simple and consistent.


Right, I was thinking about bits per second :)




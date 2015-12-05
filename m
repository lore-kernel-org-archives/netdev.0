From: David Miller <davem@davemloft.net>
Subject: Re: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does
 not?
Date: Sat, 05 Dec 2015 13:07:30 -0500 (EST)
Message-ID: <20151205.130730.864484715672273318.davem@davemloft.net>
References: <1448976655.3349108.454655833.599EFE94@webmail.messagingengine.com>
	<20151201.120851.2159228528635979581.davem@davemloft.net>
	<566301B7.3050506@shemyak.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	pshelar@nicira.com
To: konstantin@shemyak.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbLESHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 13:07:31 -0500
In-Reply-To: <566301B7.3050506@shemyak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Shemyak <konstantin@shemyak.com>
Date: Sat, 5 Dec 2015 17:24:39 +0200

> On 01.12.2015 19:08, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Tue, 01 Dec 2015 14:30:55 +0100
>>
>>> On Tue, Dec 1, 2015, at 14:20, Konstantin Shemyak wrote:
>>>> My point was not to question its feasibility, but to make it similar
>>>> across GRE, IP-IP and SIT tunnels.
>>>
>>> I would send a patch to add it again if Parvin didn't have good
>>> reasons
>>> to remove it.
>>
>> The tunnel code consolidation created a lot of regressions and subtle
>> unintended changes in behavior between the different tunnel types.
>>
>> This DF bit issue is just yet another example of that.
> 
> The patch is rather trivial; attached.

No signoff, so I can't apply this.

Also patches should be submitted as fresh mailing list postings,
with the patch inline rather than as an attachment.

Thanks.

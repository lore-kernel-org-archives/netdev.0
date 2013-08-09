From: Kumar Gaurav <kumargauravgupta3@gmail.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 09:08:04 +0530
Message-ID: <5204641C.3090905@gmail.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>  <20130808210918.GE5502@mwanda>  <20130808.142054.1541424422807503741.davem@davemloft.net>  <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com>  <1376015984.2087.31.camel@joe-AO722> <520457AD.9060508@gmail.com>  <1376016864.2087.34.camel@joe-AO722> <52045B31.9000002@gmail.com> <1376018881.2087.48.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dan.carpenter@oracle.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47738 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967470Ab3HIDiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 23:38:15 -0400
In-Reply-To: <1376018881.2087.48.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 August 2013 08:58 AM, Joe Perches wrote:
> On Fri, 2013-08-09 at 08:30 +0530, Kumar Gaurav wrote:
>> On Friday 09 August 2013 08:24 AM, Joe Perches wrote:
>>> On Fri, 2013-08-09 at 08:15 +0530, Kumar Gaurav wrote:
>>>> On Friday 09 August 2013 08:09 AM, Joe Perches wrote:
>>> []
>>>>> And, maybe it'd be better to use IRQF_TRIGGER_NONE
>>>>> instead of 0.
>>>> I tried googling what to replace IRQF_DISABLED with but found nothing.
>>>> In the patch fixed earlier (not by me) it was replaced with 0 so i did
>>>> same. But from now on I'll use IRQF_TRIGGER_NONE. Thanks
>>> Maybe that's not the right thing to do.
>>> 0 is what's almost exclusively used.
>>> IRQF_TRIGGER_NONE is only used a few times.
>>> It's also a lot longer.
>>>
>> Sorry to poke back. But just want to confirm. I should use
>> IRQF_TRIGGER_NONE and not 0 right?
> Hi again Kumar.
>
> There's no rush to submit these sorts of patches.
> Nothing is going to really be improved because of these
> changes.
>
> Submit an overall rfc patch description to the various
> mailing lists (affected MAINTAINERS generally don't read
> lkml but do read their specific mailing list) with options
> like 0 or IRQF_TRIGGER_NONE to show what the issues are
> and why you're doing this.
>
> Wait at least a week for any comment.
>
> You'll likely get some "useless churn" emails.
> You can generally ignore those.
>
> If you get any real comments, deal with them.
>
> Then after at least that week passes, submit the patches.
>
> cheers, Joe
>
Will surely follow that thanks :)

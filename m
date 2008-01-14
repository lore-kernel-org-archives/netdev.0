From: Mark Seger <Mark.Seger@hp.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 13:51:51 -0500
Message-ID: <478BAF47.10607@hp.com>
References: <478B99E6.2050800@hp.com> <478BA53B.9060504@candelatech.com> <478BA8D7.8050803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:38279 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbYANSwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 13:52:08 -0500
In-Reply-To: <478BA8D7.8050803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore that last one as it was pointed out to me that we have both nic 
installed on many of our systems and ethtool told me the one associated 
with the nic is actually the broadcom one.

version:        1.4.38 E1B1EC867DEEB8027B2DA0F
license:        GPL
description:    Broadcom NetXtreme II BCM5706/5708 Driver

-mark

Mark Seger wrote:
> I'll try to get data on the other systems reporting it and as I said 
> it does not  happen all that often AND you have to be looking for it.  
> The system I've personally seen it happen on several times is running 
> RHEL4/U4 which redhat numbers 2.6.9-42 and from modinfo I see:
> version:        7.0.33-k2-NAPI 51E97FEE51D0772AFC89130
> description:    Intel(R) PRO/1000 Network Driver
>
> -mark
>
> Ben Greear wrote:
>> Mark Seger wrote:
>>> I had posted the following on linux-net and haven't see any 
>>> responses possibly because nobody had any or that list is obsolete.  
>>> I have been told this is the current list for everything networking 
>>> on linux so I thought I'd try again...
>> Do you see this with multiple network drivers, or just with one 
>> particular driver.  If so, which one?
>>
>> Thanks,
>> Ben
>>


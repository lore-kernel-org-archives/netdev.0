From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH net-next] enic: Add support for adaptive interrupt
 coalescing
Date: Thu, 8 May 2014 11:43:03 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1405081126320.1536@cisco.com>
References: <1399386262-20769-1-git-send-email-_govind@gmx.com> <20140507.170043.896249393177676627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, neepatel@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-3.cisco.com ([72.163.197.27]:13278 "EHLO
	bgl-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaEHGXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 02:23:10 -0400
In-Reply-To: <20140507.170043.896249393177676627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 May 2014, David Miller wrote:

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Tue,  6 May 2014 19:54:22 +0530
>
>> From: Sujith Sankar <ssujith@cisco.com>
>>
>> Signed-off-by: Sujith Sankar <ssujith@cisco.com>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>
> Please never submit patches except absolutely the most extremely
> trivial ones without a real commit log message explaining what
> the change does, how it does it, and why you implemented it that
> way.
>

Will add more description. Sorry

>> +enum hrtimer_restart enic_hrtimer_cb(struct hrtimer *timer)
>> +{
>> +	return HRTIMER_RESTART;
>> +}
>
> For example, I have no idea why in the world you need an hrtimer whose
> function is a complete NOP if the networking hardware does the
> interrupt coalescing for you.
>

The idea was to get time delta in usec, to measure the pkt rate. We want to 
make damping of coal timer more aggressive. I guess we can use ktime_get() 
instead of hrtimers.

Will resubmit the patch with changes in a week. Let us know if anything else 
needs to be changed.

thanks
Govind

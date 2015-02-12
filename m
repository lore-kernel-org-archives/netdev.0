From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Fix key serialization.
Date: Thu, 12 Feb 2015 12:41:43 -0800
Message-ID: <CALnjE+pZ2mxMhcJiaP9V4YOSLDrvO-Hi_Om2Fu7QTQhX1N9B8g@mail.gmail.com>
References: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
	<CANr6G5yyTRwwvgzB-eZE0-7UDP_P31+RQvYe0oWZh=prTStSMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:33411 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750912AbbBLUlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:41:44 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so6440439igk.1
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 12:41:43 -0800 (PST)
In-Reply-To: <CANr6G5yyTRwwvgzB-eZE0-7UDP_P31+RQvYe0oWZh=prTStSMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2015 at 11:02 AM, Joe Stringer <joestringer@nicira.com> wrote:
> On 12 February 2015 at 09:58, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Fix typo where mask is used rather than key.
>>
>> Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
>> Reported-by: Joe Stringer <joestringer@nicira.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>
> Thanks for looking into this. So in general we zero-initialize the
> key, but not the mask---then use the key to determine which parts of
> the key (or mask) to serialize?
>
Mask is also initialized in ovs_match_init().


> This fixes the problem I was seeing.
>
> Acked-by: Joe Stringer <joestringer@nicira.com>

Thanks.

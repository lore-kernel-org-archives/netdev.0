From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] net: The beginning of the end for
 NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
Date: Tue, 15 Dec 2015 14:18:00 -0800
Message-ID: <CALx6S36pX3X5HZTd0TXG-6DHuAoEkLU=-SOyr3MuwsdcsnbRcA@mail.gmail.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
	<20151215.163233.1822498299187427740.davem@davemloft.net>
	<CALx6S366Qu7+AJPe_ZHpECeaa+EeZeANXvQ4UPC7E=uft4mgdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33010 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932654AbbLOWSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 17:18:01 -0500
Received: by mail-io0-f182.google.com with SMTP id 186so36280858iow.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 14:18:00 -0800 (PST)
In-Reply-To: <CALx6S366Qu7+AJPe_ZHpECeaa+EeZeANXvQ4UPC7E=uft4mgdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 2:11 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Dec 15, 2015 at 1:32 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Mon, 14 Dec 2015 11:19:39 -0800
>>
>>> This patch set starts to address one front in the battle against
>>> protocol ossification.
>>
>> Looks good series applied, thanks.
>>
>> Two things:
>>
>> 1) I'd ask you to reconsider passing that struct with the bit fields into
>>    the chk routines.  Some cpu ABIs pass that thing as an aggregate on
>>    the stack.  Whereas if you just use a simple bit mask and BIT(x) values
>>    we know it's always going to be passed in as an integer or whatever.
>>
>> 2) As per the TCP check, it is definitely more strict now.  But I seriously
>>    doubt get ever gained anything real with the previous, looser, check.
>>    Besides, if it bites a user segment we will get a report and can adjust
>>    things.
>>
>> Thanks!
>
> Looks like I may have missed a NETIF_F_ALL_CSUM in netronome driver,
> will post fix shortly.

Actually looks okay, did you fix this up Dave?

Thanks,
Tom

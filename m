From: Syed Obaid Amin <obaidasyed@gmail.com>
Subject: Re: About disabling congestion control
Date: Fri, 7 Jan 2011 05:04:58 -0500
Message-ID: <AANLkTi=FLGM1z0VLH+WZXvF=7TZHtMhxLe+KRF3ojWR1@mail.gmail.com>
References: <AANLkTin53drsv18TZ0CPZM7==6G=rK6vScUb=SCQ4-xr@mail.gmail.com>
	<20110106173758.37bfef4d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45121 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585Ab1AGKE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 05:04:59 -0500
Received: by fxm20 with SMTP id 20so16790089fxm.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 02:04:58 -0800 (PST)
In-Reply-To: <20110106173758.37bfef4d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reply. Yes I also thought to create a sort of NULL
congestion control type that does nothing. But this way the changes
would be system wide. BTW, would some one share the insight that why
linux uses sysctl to select a congestion control algorithm instead of
socket options.

Thanks again,

Obaid

On Thu, Jan 6, 2011 at 8:37 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Thu, 6 Jan 2011 20:25:18 -0500
> Syed Obaid Amin <obaidasyed@gmail.com> wrote:
>
>> Hey all,
>>
>> I am currently working on a socket option to disable the tcp
>> congestion control. I think the simplest approach to do this is to
>> ignore cwnd before sending out a packet.
>>
>> After going through tcp output engine it seems that tcp_cwnd_test is
>> the method that decides that how many segments can be sent out on a
>> wire. For testing it out, I changed this method so that if no-cc
>> option is ON, just return a big constant value. But, it didn't work
>> and I am unable to see a burst of pkts. It looks like that I am
>> missing something here.
>>
>> Any suggestions that what is the right place to look for disabling the
>> congestion control ?
>>
>> Thanks much!
>>
>> Obaid
>
> I assume this is just a local hack experiment; not something you
> want to actually submit for other users to use...
>
> The easiest/safest way to do this would be to build/define a new TCP congestion
> control type that does nothing.
>
>

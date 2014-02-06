From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Thu, 6 Feb 2014 14:18:14 -0800
Message-ID: <CAHA+R7NkLnh5xpca7nQbf99kAqqLW4trR4AEKXgn3Oad6_NBjg@mail.gmail.com>
References: <20140205141539.450095fa@samsung-9>
	<52F30863.7000206@lab.ntt.co.jp>
	<CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>
	<52F3214C.4060308@lab.ntt.co.jp>
	<CAHA+R7Ork+gER_v=YhQCSDO9N=aokXiSiMUWwD3aMSv2YaZJ4g@mail.gmail.com>
	<52F34D41.8000704@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:63825 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbaBFWSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:18:16 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so1970267lan.40
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:18:15 -0800 (PST)
In-Reply-To: <52F34D41.8000704@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 12:52 AM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> (2014/02/06 15:49), Cong Wang wrote:
>> On Wed, Feb 5, 2014 at 9:44 PM, Toshiaki Makita
>> <makita.toshiaki@lab.ntt.co.jp> wrote:
>>> Tested this patch with latest net-tree and netconsole works with it.
>>> But I thinks it is better to move that "if" to br_add_if() because if we
>>> don't have npinfo, we don't have to alloc p->np in br_add_if(), right?
>>>
>>
>> Hmm, we shouldn't handle netpoll-specific code inside br_add_if(),
>> we probably need the attached patch instead. Please give it
>> a try, or I will test it tomorrow, it's too late here.
>>
>
> I tested whether netconsole works and whether it can be built
> with/without CONFIG_NET_POLL_CONTROLLER, and couldn't find any problem.
> This looks good to me.
>

Excellent! I will send it formally.

Thanks for testing!

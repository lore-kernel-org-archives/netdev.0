From: Cong Wang <cwang@twopensource.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Tue, 14 Oct 2014 14:24:05 -0700
Message-ID: <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	<20141014.164705.1874094084240216813.davem@davemloft.net>
	<CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
	<20141014.171559.1355616486999711590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:50258 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932569AbaJNVYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:24:06 -0400
Received: by mail-qa0-f54.google.com with SMTP id i13so6638122qae.27
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 14:24:05 -0700 (PDT)
In-Reply-To: <20141014.171559.1355616486999711590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 2:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <edumazet@gmail.com>
> Date: Tue, 14 Oct 2014 14:03:51 -0700
>
>> 2014-10-14 13:47 GMT-07:00 David Miller <davem@davemloft.net>:
>>>
>>>
>>> > Patch looks good, but seems a net-next candidate to me.
>>>
>>> I thought it is a potential fix for this corruption report?
>>
>>
>> Sure, but a one liner fix seemed more obvious, as it points to the problem.
>>
>> I do not particularly care, as long as we fixed the bug.


Since we are still in merge window, I don't think we have to use
a one-line fix for a bug introduced in this merge window.

>
> Ok, let's get testing feedback and then I'll look for a formal submission.

Yeah, there is no evidence to say my patch fixes the bug Krzysztof
reported before he tests it, I found it during code review.

Thanks!

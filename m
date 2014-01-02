From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Thu, 2 Jan 2014 10:13:27 -0800
Message-ID: <CA+mtBx_-kzKYLYww8C6AXX33DzxPxMX9enGj4QXJZWjDFghVKg@mail.gmail.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.133200.1111966466957616549.davem@davemloft.net>
	<CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
	<CAEH94LiYzvHFy-5oMOnkj8KJAZXUnY+wcrkFAMnrjkOM4Sb6hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Jerry Chu <hkchu@google.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:62005 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaABSN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:13:28 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so15021619ieb.39
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 10:13:28 -0800 (PST)
In-Reply-To: <CAEH94LiYzvHFy-5oMOnkj8KJAZXUnY+wcrkFAMnrjkOM4Sb6hA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+hkchu

I believe Jerry Chu was using a little uspace program to turn tun into
a network interface so that netperf and others can easily be run.
Jerry, can you share how you did that?

Thanks,
Tom

On Tue, Dec 31, 2013 at 10:44 PM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> On Wed, Jan 1, 2014 at 6:33 AM, Tom Herbert <therbert@google.com> wrote:
>> Zhi,
>>
>> Thanks for following up on these patches. It would still be nice to
>> have performance numbers to show the impact. These will be helpful for
>> the next task of integrating RFS into virtio-net.
> Will try to do them after holiday, if you have any special test cases,
> please let me know, thanks.
>
>>
>> Tom
>>
>> On Tue, Dec 31, 2013 at 10:32 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>>> Date: Sun, 22 Dec 2013 18:54:30 +0800
>>>
>>>> Since Tom Herbert's hash related patchset was modified and got merged,
>>>> his pachset about adding support for RFS on tun flows also need to get
>>>> adjusted accordingly. I tried to update them, and before i will start
>>>> to do some perf tests, i hope to get one correct code base, so it's time
>>>> to post them out now. Any constructive comments are welcome, thanks.
>>>
>>> Series applied to net-next, thanks.
>
>
>
> --
> Regards,
>
> Zhi Yong Wu

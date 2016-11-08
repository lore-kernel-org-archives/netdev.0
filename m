From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine macpower
Date: Tue, 08 Nov 2016 09:29:07 -0500
Message-ID: <wrfjh97i11vw.fsf@redhat.com>
References: <CANf5e8aQ+HZz47M3-4+qjsG=ZCaXhBFU_jVupLqT4rEYT2LQFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joe Perches <joe@perches.com>, John Heenan <john@zgus.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Dave Jones <s.dave.jones@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933992AbcKJPyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:54:00 -0500
In-Reply-To: <CANf5e8aQ+HZz47M3-4+qjsG=ZCaXhBFU_jVupLqT4rEYT2LQFQ@mail.gmail.com>
        (Dave Jones's message of "Tue, 8 Nov 2016 09:45:12 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <s.dave.jones@gmail.com> writes:
> On Fri, Nov 04, 2016 at 09:56:00AM -0400, Jes Sorensen wrote:
>>
>> Joe Perches <joe@perches.com> writes:
>> > On Sun, 2016-10-30 at 19:02 -0400, Jes Sorensen wrote:
>> >> Code is 80 characters wide, and comments are /* */ never the ugly C++
>> >> crap.
>> >
>> > You might look at the recent Linus Torvalds authored commit
>> > 5e467652ffef (?printk: re-organize log_output() to be more legible")
>> > which does both of those: c99 // comments and > 80 columns.
>> >
>> > Absolutes are for zealots.
>>
>> What Linus does in his code, is totally up to him. What I pull into the
>> driver that *I* maintain, is up to me. It is perfectly normal to expect
>> submitters to respect the coding style of the piece of code they are
>> trying to edit.
>
> Bullshit.  It's perfectly normal to respect Linux coding style described in
> Documentation/CodingStyle.  Now let's back to the topic, could you
> apply John's patch or you just wanna improve your driver is 100% bug free?

First of all, I call for proper CodingStyle to be applied to my driver,
and I expect someone posting a patch to respect the codingstyle of the
driver in question. It is simple respect for the code. If you consider
that BS - that is on you!

Second I am NOT applying that patch as I have stated repeatedly because
I am not convinced it is safe to do so and it changes the code flow for
one type of chip and not the rest. In addition it uses a broken approach
to doing chip specific changes.

In short, the patch is broken!

Jes

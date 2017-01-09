From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Mon, 09 Jan 2017 22:44:35 +0200
Message-ID: <87inpot13g.fsf@kamboji.qca.qualcomm.com>
References: <20170108.223847.1035900535306187665.davem@davemloft.net>
        <CA+55aFzjL6Tf7JazeZtbi9UARhqofWU8xzYm0rbdAeCsD+nMPw@mail.gmail.com>
        <20170109.152437.40458564953109123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, Larry.Finger@lwfinger.net,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170109.152437.40458564953109123.davem@davemloft.net> (David
        Miller's message of "Mon, 09 Jan 2017 15:24:37 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 9 Jan 2017 12:08:02 -0800
>
>> On Sun, Jan 8, 2017 at 7:38 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>> 
>> Hmm. This still doesn't contain the rtlwifi oops fix that was posted
>> back before christmas.
>> 
>> Kalle said it was applied to the wireless-drivers tree as commit
>> 60f59ce02785 in his tree, but it's never gotten to me.
>> 
>> What's up? It's three weeks later, and people are hitting the bug.
>
> I haven't received a bug fix pull from Kalle since Dec 22nd:
>
> 	http://patchwork.ozlabs.org/patch/708247/
>
> That one has:
>
>       rtlwifi: Fix kernel oops introduced with commit e49656147359
>
> Is that what you're talking about?
>
> In the thread I said I pulled it but indeed I don't have that commit
> in my tree either, weird.
>
> I just tried to pull that git URL right now and I get nothing:
>
> 	git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-12-22
>
> It looks like the rtlwifi fix is in his "pending" branch.

Be careful, there are two recent rtlwifi fixes in wireless-drivers:

60f59ce02785 rtlwifi: rtl_usb: Fix missing entry in USB driver's private data
22b68b93ae25 rtlwifi: Fix kernel oops introduced with commit e49656147359

You should have 22b68b93ae25 in your tree, but not 60f59ce02785. The
reason why you didn't get 60f59ce02785 in my pull request was that I
committed it late:

commit 60f59ce0278557f7896d5158ae6d12a4855a72cc
Author:     Larry Finger <Larry.Finger@lwfinger.net>
AuthorDate: Wed Dec 21 11:18:55 2016 -0600
Commit:     Kalle Valo <kvalo@codeaurora.org>
CommitDate: Fri Dec 30 15:38:13 2016 +0200

I'll send you a new pull request tomorrow (my time).

-- 
Kalle Valo

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Mon, 09 Jan 2017 22:34:43 +0200
Message-ID: <87r34ct1jw.fsf@kamboji.qca.qualcomm.com>
References: <20170108.223847.1035900535306187665.davem@davemloft.net>
        <CA+55aFzjL6Tf7JazeZtbi9UARhqofWU8xzYm0rbdAeCsD+nMPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzjL6Tf7JazeZtbi9UARhqofWU8xzYm0rbdAeCsD+nMPw@mail.gmail.com>
        (Linus Torvalds's message of "Mon, 9 Jan 2017 12:08:02 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Sun, Jan 8, 2017 at 7:38 PM, David Miller <davem@davemloft.net> wrote:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>
> Hmm. This still doesn't contain the rtlwifi oops fix that was posted
> back before christmas.
>
> Kalle said it was applied to the wireless-drivers tree as commit
> 60f59ce02785 in his tree, but it's never gotten to me.
>
> What's up? It's three weeks later, and people are hitting the bug.

You mean this one:

60f59ce02785 rtlwifi: rtl_usb: Fix missing entry in USB driver's private data

I accidentally missed the patch during my holiday pull request,
committed the patch late, and I haven't sent a new pull request since.
Also the commit log didn't mention anything about an oops, only about
"missing an entry", so I didn't realise it was a critical fix.

Sorry about that, I'll send a new pull request to Dave first thing
tomorrow. It's too late now for me.

-- 
Kalle Valo

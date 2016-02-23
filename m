From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH] net: jme: fix suspend/resume on JMC260
Date: Tue, 23 Feb 2016 02:11:43 -0300
Message-ID: <CA+ToGPFYVb_swmD_-+TRMO4Pc5bP2gFKnBx1JSgC1Jb_S4Pb6g@mail.gmail.com>
References: <1456187572-2964-1-git-send-email-diego.viola@gmail.com>
	<CAOMZO5Br8mBWOFcdw6i7=VBKtwQsVFMzEYK=CoowG90ExUCCGg@mail.gmail.com>
	<CA+ToGPGLc38aVdkSYsx_QtgFADouZQsRBxD_U-m0fy79fJgCFA@mail.gmail.com>
	<20160222.234234.1952119173455287427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: festevam@gmail.com, cooldavid@cooldavid.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard.weinberger@gmail.com, pavel@ucw.cz, rjw@rjwysocki.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160222.234234.1952119173455287427.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2016 at 1:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Diego Viola <diego.viola@gmail.com>
> Date: Mon, 22 Feb 2016 22:58:48 -0300
>
>> On Mon, Feb 22, 2016 at 10:46 PM, Fabio Estevam <festevam@gmail.com> wrote:
>>> On Mon, Feb 22, 2016 at 9:32 PM, Diego Viola <diego.viola@gmail.com> wrote:
>>>> Signed-off-by: Diego Viola <diego.viola@gmail.com>
>>>
>>> You should write a commit log.
>>
>> I thought about including the link to my bug report:
>> https://bugzilla.kernel.org/show_bug.cgi?id=112351
>>
>> What else would you suggest I add to the commit message?
>
> The commit message is where you describe the change you are making.
>
> This includes exactly what you are fixing, how you are doing it, and why
> you are doing it that way.
>
> Empty commit log messages are %99.99999 of the time completely
> inappropriate.

David,

I understand and appreciate your advice, thanks.

However, please consider that I'm not a kernel developer, so I don't
understand much or anything about how this driver works internally,
this is why I came here to report about problem in the first place.

All I can tell you for certain is that this change makes my
suspend/resume work and it doesn't hang anymore while resuming from
suspend.

I apologize for the empty commit message and for not being able to
explain things deeper, but Pavel Machek is the person who suggested I
make this change in the code, so maybe he can provide some help?

Diego

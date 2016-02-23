From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH] net: jme: fix suspend/resume on JMC260
Date: Mon, 22 Feb 2016 23:35:15 -0300
Message-ID: <CA+ToGPFiObFPCAOX1BT1XPaGqB+PF0HbE=zNZPr0Bm8M9CTkeA@mail.gmail.com>
References: <1456187572-2964-1-git-send-email-diego.viola@gmail.com>
	<CAOMZO5Br8mBWOFcdw6i7=VBKtwQsVFMzEYK=CoowG90ExUCCGg@mail.gmail.com>
	<CA+ToGPGLc38aVdkSYsx_QtgFADouZQsRBxD_U-m0fy79fJgCFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cooldavid@cooldavid.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Pavel Machek <pavel@ucw.cz>,
	"rjw@rjwysocki.net" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ToGPGLc38aVdkSYsx_QtgFADouZQsRBxD_U-m0fy79fJgCFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 10:58 PM, Diego Viola <diego.viola@gmail.com> wrote:
> On Mon, Feb 22, 2016 at 10:46 PM, Fabio Estevam <festevam@gmail.com> wrote:
>> On Mon, Feb 22, 2016 at 9:32 PM, Diego Viola <diego.viola@gmail.com> wrote:
>>> Signed-off-by: Diego Viola <diego.viola@gmail.com>
>>
>> You should write a commit log.
>
> I thought about including the link to my bug report:
> https://bugzilla.kernel.org/show_bug.cgi?id=112351
>
> What else would you suggest I add to the commit message?
>
> Diego

I probably should have explained also that this patch fixes my
suspend/resume problem even when /sys/power/pm_async is set to 1,
because before that, suspend/resume only worked when pm_async was 0.

I had a chat with Guo a few minutes ago on Hangouts and he said he
will look into this problem. :)

Diego

From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not processed' messages
Date: Sat, 24 Sep 2016 16:35:24 -0400
Message-ID: <wrfjzimxrq7n.fsf@redhat.com>
References: <1474654333.1849.5.camel@perches.com>
        <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
        <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
        <1474657363.1849.9.camel@perches.com>
        <20160924175555.01cae6dd@endymion>
        <1474733754.23838.3.camel@perches.com>
        <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
        <1474738358.23838.11.camel@perches.com>
        <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net>
        <1474748954.23838.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474748954.23838.21.camel@perches.com> (Joe Perches's message of
        "Sat, 24 Sep 2016 13:29:14 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:
> On Sat, 2016-09-24 at 14:06 -0500, Larry Finger wrote:
>> On 09/24/2016 12:32 PM, Joe Perches wrote:
> []
>> o Reindent all the switch/case blocks to a more normal
>>   kernel style (git diff -w would show no changes here)
>> That sounds like busy work to me, but if you want to do it, go ahead.
>
> It's really just to make the comparison case block reductions
> easier to verify for later steps done
>
>> > o cast, spacing and parenthesis reductions
>> >   Lots of odd and somewhat unique styles in various
>> >   drivers, looks like too many individual authors without
>> >   a style guide / code enforcer using slightly different
>> >   personalized code.  Glancing at the code, it looks to be
>> >   similar logic, just written in different styles.
>> Same comment.
>
> Same rationale
>
>> > o Logic changes like
>> >   from:
>> >     if (foo) func(..., bar, ...); else func(..., baz, ...);
>> >   to:
>> >     func(..., foo ? bar : baz, ...);
>> >   to make the case statement code blocks more consistent
>> >   and emit somewhat smaller object code.
>> I find if .. else constructs much easier to read than the cond ? xxxx : yyyy 
>> form. I would reject any such patches.
>
> <shrug> I think object code reduction generally a good thing
> but then again, I'm not a maintainer here.

I missed this part, but I am with Larry here - 'foo ? bar : boo' are
just obfuscating the code and far less clear than if or switch
statements.

Jes

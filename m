From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 00/58] networking: Convert timers to use timer_setup()
Date: Wed, 18 Oct 2017 08:44:57 +0300
Message-ID: <87h8ux2ena.fsf@codeaurora.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
        <87mv4pvowa.fsf@purkki.adurom.net>
        <CAGXu5j+fcARk=yWh9Bbkn0C-4PHd+pKSPGV+5qPx88H6prvUoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+fcARk=yWh9Bbkn0C-4PHd+pKSPGV+5qPx88H6prvUoA@mail.gmail.com>
        (Kees Cook's message of "Tue, 17 Oct 2017 12:47:26 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> writes:

> On Tue, Oct 17, 2017 at 7:18 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> + linux-wireless
>>
>> Hi Kees,
>>
>> Kees Cook <keescook@chromium.org> writes:
>>
>>> This is the current set of outstanding networking patches to perform
>>> conversions to the new timer interface (rebased to -next). This is not
>>> all expected conversions, but it contains everything needed in networking
>>> to eliminate init_timer(), and all the non-standard setup_*_timer() uses.
>>
>> So this also includes patches which I had queued for
>> wireless-drivers-next:
>>
>> https://patchwork.kernel.org/patch/9986253/
>> https://patchwork.kernel.org/patch/9986245/
>>
>> And looking at patchwork[1] I have even more timer_setup() related
>> patches from you. It would be really helpful if you could clearly
>> document to which tree you want the patches to be applied. I don't care
>
> Hi! Sorry about that. It's been a bit tricky to juggle everything.

Yeah, I understand.

>> if it's net-next or wireless-drivers-next as long as it's not the both
>> (meaning that both Dave and me apply the same patch, which would be
>> bad). The thing is that I really do not have time to figure out for
>> every patch via which tree it's supposed to go.
>
> Which split is preferred? I had been trying to separate wireless from
> the rest of net (but missed some cases).

So what we try to follow is that I apply all patches for
drivers/net/wireless to my wireless-drivers trees, with exception of
Johannes taking mac80211_hwsim.c patches to his mac80211 trees. And
Johannes of course takes all patches for net/wireless and net/mac80211.

So in general I prefer that I take all drivers/net/wireless patches and
make it obvious for Dave that he can ignore those patches (not mix
wireless-drivers and net patches into same set etc). But like I said,
it's ok to push API changes like these via Dave's net trees as well if
you want (and if Dave is ok with that). The chances of conflicts is low,
and if there are be any those would be easy to fix either by me or Dave.

>> For now I'll just drop all your timer_setup() related patches from my
>> queue and I'll assume Dave will take those. Ok?
>>
>> [1] https://patchwork.kernel.org/project/linux-wireless/list/
>
> I guess I'll wait to see what Dave says.

Ok, I don't drop the patches from my queue quite yet then.

-- 
Kalle Valo

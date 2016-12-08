From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: deadlock on genl_mutex
Date: Thu, 8 Dec 2016 17:16:07 +0100
Message-ID: <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com> <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        netdev-owner@vger.kernel.org
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 6:59 AM,  <subashab@codeaurora.org> wrote:
>>
>> Issue was reported yesterday and is under investigation.
>>
>>
>> http://marc.info/?l=linux-netdev&m=148014004331663&w=2
>>
>>
>> Thanks !
>
>
> Hi Dmitry
>
> Can you try the patch below with your reproducer? I haven't seen similar
> crashes reported after this (or even with Eric's patch).

I've synced to 318c8932ddec5c1c26a4af0f3c053784841c598e (Dec 7) and do
_not_ see this report happening anymore.
Thanks.

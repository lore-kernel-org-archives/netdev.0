From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] drivers/net/wan/z85230.c: Use designated initializers
Date: Tue, 1 Aug 2017 17:33:59 -0700
Message-ID: <CAGXu5jJOsTfpBOzg1AkVyCch6x06EDDkFU8aCZG7fNPrxJY8QQ@mail.gmail.com>
References: <20170731013117.GA67801@beast> <20170801.152943.804666349488319640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801.152943.804666349488319640.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 1, 2017 at 3:29 PM, David Miller <davem@davemloft.net> wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Sun, 30 Jul 2017 18:31:17 -0700
>
>> In preparation for the randstruct gcc plugin performing randomization of
>> structures that are entirely function pointers, use designated initializers
>> so the compiler doesn't get angry.
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> This is a prerequisite for the future randstruct fptr randomization. I'd
>> prefer to carry this in my gcc-plugin tree for v4.14 with an Ack from
>> someone on net-dev, or if possible, have it applied to v4.13 via net-dev.
>
> Please queue this up into the gcc-plugin tree then:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> It isn't a bug fix so I would only have put it into 'net-next' rather
> than 'net'.

Okay, sounds good. I'll carry it. Thanks!

-Kees

-- 
Kees Cook
Pixel Security

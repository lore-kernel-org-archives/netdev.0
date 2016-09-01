From: Robert Foss <robert.foss@collabora.com>
Subject: Re: [PATCH v3 5/5] net: asix: autoneg will set WRITE_MEDIUM reg
Date: Thu, 1 Sep 2016 12:47:27 -0400
Message-ID: <18052c6d-2cb1-0927-7d33-92d4bd397aa4@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <9d5c5525f369f1c4098bda989d73886d11036bae.1472155176.git-series.robert.foss@collabora.com>
 <1472748216.5019.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: freddy@asix.com.tw, Dean_Jenkins@mentor.com,
        Mark_Craske@mentor.com, davem@davemloft.net, ivecera@redhat.com,
        john.stultz@linaro.org, vpalatin@chromium.org,
        stephen@networkplumber.org, grundler@chromium.org,
        changchias@gmail.com, allan@asix.com.tw, andrew@lunn.ch,
        tremyfr@gmail.com, colin.king@canonical.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vpalatin@google.com,
        Grant Grundler <grundler@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472748216.5019.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016-09-01 12:43 PM, Eric Dumazet wrote:
> On Mon, 2016-08-29 at 09:32 -0400, robert.foss@collabora.com wrote:
>> From: Robert Foss <robert.foss@collabora.com>
>>
>> From: Grant Grundler <grundler@chromium.org>
>>
>> The miii_nway_restart() causes a PHY link change activity and
>> ax88772_link_reset will be called. link_reset will set
>> AX_CMD_WRITE_MEDIUM_MODE register correctly.
>>
>> The asix_write_medium_mode in reset() fills in a default value to the register
>> which may be different from the negotiation result. So do this first.
>>
>> Ignore the ret value since it's ignored in XXX_link_reset() functions.
>>
>> Signed-off-by: Grant Grundler <grundler@google.com>
>> Signed-off-by: Robert Foss <robert.foss@collabora.com>
>> Tested-by: Robert Foss <robert.foss@collabora.com>
>> ---
>
> This is _really_ confusing Robert.
>
> Why having two 'From:' clauses ?
>
> Who wrote the patch in the first place ? You or Grant ?

I'm not quite sure how the first From line was added, it
should not have been.
Grant Grundler is most definitely the author.

Would you like me to resubmit in v++ and make sure that it has been 
corrected?

>
>
>
> End result is :
>
> commit 535baf8588d04b177cb33700f81499f2b5203c2d
> Author: Robert Foss <robert.foss@collabora.com>
> Date:   Mon Aug 29 09:32:19 2016 -0400
>
>     net: asix: autoneg will set WRITE_MEDIUM reg
>
>     From: Grant Grundler <grundler@chromium.org>
>
>     The miii_nway_restart() causes a PHY link change activity and
>     ax88772_link_reset will be called. link_reset will set
>     AX_CMD_WRITE_MEDIUM_MODE register correctly.
>
>     The asix_write_medium_mode in reset() fills in a default value to the register
>     which may be different from the negotiation result. So do this first.
>
>     Ignore the ret value since it's ignored in XXX_link_reset() functions.
>
>     Signed-off-by: Grant Grundler <grundler@google.com>
>     Signed-off-by: Robert Foss <robert.foss@collabora.com>
>     Tested-by: Robert Foss <robert.foss@collabora.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>
> I guess Grant wrote the patch, but attribution is wrong.
>
>

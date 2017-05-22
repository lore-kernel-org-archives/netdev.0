From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCHv4] wlcore: add wl1285 compatible
Date: Mon, 22 May 2017 17:44:24 +0300
Message-ID: <87wp99t0hj.fsf@kamboji.qca.qualcomm.com>
References: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
        <8737bx5jgr.fsf@purkki.adurom.net>
        <20170522.103010.1779800840743690143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: sebastian.reichel@collabora.co.uk, sre@kernel.org,
        tony@atomide.com, marcel@holtmann.org, robh+dt@kernel.org,
        linux-wireless@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522.103010.1779800840743690143.davem@davemloft.net> (David
        Miller's message of "Mon, 22 May 2017 10:30:10 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Mon, 22 May 2017 12:28:20 +0300
>
>> Sebastian Reichel <sebastian.reichel@collabora.co.uk> writes:
>> 
>>> Motorola Droid 4 uses a WL1285C. With differences between the
>>> chips not being public let's add explicit binding for wl1285
>>> instead of relying on wl1283 being very similar.
>>>
>>> Reviewed-by: Rob Herring <robh@kernel.org>
>>> Acked-by: Kalle Valo <kvalo@codeaurora.org>
>>> Acked-by: Tony Lindgren <tony@atomide.com>
>>> Signed-off-by: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
>>> ---
>>> Hi Dave,
>>>
>>> I previously send this in two patches, but its hard to apply without
>>> requiring multiple kernel releases (the driver must be updated before
>>> the DTS change). Since the actual change is not very complex Marcel
>>> Holtmann & Tony Lindgren suggested, that I send this directly to you
>>> in a single patch for inclusion into 4.12. This also means, that the
>>> remaining series can be queued normally for 4.13.
>> 
>> I noticed that Dave set this patch to Awaiting Upstream state on his
>> patchwork:
>> 
>> https://patchwork.ozlabs.org/patch/759042/
>> 
>> Which makes me suspect that he is waiting me to apply this (as I
>> normally apply wlcore patches). Dave, should I actually take this patch?
>> What do you prefer?
>
> Anything that touches wireless drivers I defer to you, yes.

Thanks, I'll take it then. Not sure why Sebastian was suggested to
submit this patch via your tree in the first place.

https://patchwork.kernel.org/patch/9713645/

-- 
Kalle Valo

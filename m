From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Fri, 12 May 2017 11:54:55 +0300
Message-ID: <87d1beqwtc.fsf@kamboji.qca.qualcomm.com>
References: <20170512073555.12333-1-cheerx1994@gmail.com>
        <87tw4qqyh1.fsf@kamboji.qca.qualcomm.com>
        <c5e21126-23e6-8cef-d01b-dc225dab1982@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Xie Qirong <cheerx1994@gmail.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c5e21126-23e6-8cef-d01b-dc225dab1982@broadcom.com> (Arend van
        Spriel's message of "Fri, 12 May 2017 10:36:56 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend.vanspriel@broadcom.com> writes:

> On 5/12/2017 10:19 AM, Kalle Valo wrote:
>> Xie Qirong <cheerx1994@gmail.com> writes:
>>
>>> The combination of init_timer and setting up the data and function field
>>> manually is equivalent to calling setup_timer(). This is an api
>>> consolidation only and improves readability.
>>>
>>> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
>>> Signed-off-by: Xie Qirong <cheerx1994@gmail.com>
>>> ---
>>>
>>>   setup_timer.cocci suggested the following improvement:
>>>   drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
>>>   setup_timer function for function on line 384.
>>>
>>>   Patch was compile checked with: x86_64_defconfig + CONFIG_BRCMFMAC=y +
>>>   CONFIG_BRCMFMAC_USB=y + CONFIG_BRCMFMAC_PCIE=y + CONFIG_BRCM_TRACING=y +
>>>   CONFIG_BRCMDBG=y
>>>
>>>   Kernel version: 4.11.0 (localversion-next is next-20170512)
>>
>> How is this different from the first version?
>>
>> https://patchwork.kernel.org/patch/9709467/
>
> Hi Kalle,
>
> This is actually the third version. You are referring to the
> not-specifically-named "v2" here, but how are you to know ;-) 

Exactly :)

> This third version is the same as v1 on which I commented to put the
> coccinelle output in the commit message. So I would still keep v2 if
> nothing else changed in v3 apart from my Acked-by: tag.

Ok, but I can easily take v3 (ie. this one) so that you get credit ;)

-- 
Kalle Valo

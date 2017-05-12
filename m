From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Fri, 12 May 2017 11:10:36 +0200
Message-ID: <036761ff-85a9-6042-57ed-ca3968550737@broadcom.com>
References: <20170512073555.12333-1-cheerx1994@gmail.com>
 <87tw4qqyh1.fsf@kamboji.qca.qualcomm.com>
 <c5e21126-23e6-8cef-d01b-dc225dab1982@broadcom.com>
 <87d1beqwtc.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xie Qirong <cheerx1994@gmail.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35224 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932784AbdELJKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 05:10:41 -0400
Received: by mail-qk0-f182.google.com with SMTP id a72so42591655qkj.2
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 02:10:41 -0700 (PDT)
In-Reply-To: <87d1beqwtc.fsf@kamboji.qca.qualcomm.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2017 10:54 AM, Kalle Valo wrote:
> Arend van Spriel <arend.vanspriel@broadcom.com> writes:
> 
>> On 5/12/2017 10:19 AM, Kalle Valo wrote:
>>> Xie Qirong <cheerx1994@gmail.com> writes:
>>>
>>>> The combination of init_timer and setting up the data and function field
>>>> manually is equivalent to calling setup_timer(). This is an api
>>>> consolidation only and improves readability.
>>>>
>>>> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
>>>> Signed-off-by: Xie Qirong <cheerx1994@gmail.com>
>>>> ---
>>>>
>>>>    setup_timer.cocci suggested the following improvement:
>>>>    drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
>>>>    setup_timer function for function on line 384.
>>>>
>>>>    Patch was compile checked with: x86_64_defconfig + CONFIG_BRCMFMAC=y +
>>>>    CONFIG_BRCMFMAC_USB=y + CONFIG_BRCMFMAC_PCIE=y + CONFIG_BRCM_TRACING=y +
>>>>    CONFIG_BRCMDBG=y
>>>>
>>>>    Kernel version: 4.11.0 (localversion-next is next-20170512)
>>>
>>> How is this different from the first version?
>>>
>>> https://patchwork.kernel.org/patch/9709467/
>>
>> Hi Kalle,
>>
>> This is actually the third version. You are referring to the
>> not-specifically-named "v2" here, but how are you to know ;-)
> 
> Exactly :)
> 
>> This third version is the same as v1 on which I commented to put the
>> coccinelle output in the commit message. So I would still keep v2 if
>> nothing else changed in v3 apart from my Acked-by: tag.
> 
> Ok, but I can easily take v3 (ie. this one) so that you get credit ;)

If you add the coccinelle output in the commit message, ie. above the 
'---' that would be great. So for both you have to do additional stuff 
provided you find it useful to have the coccinelle output. :-p

Regards,
Arend

From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Wed, 07 Mar 2012 09:37:14 -0800
Message-ID: <4F579CCA.2060907@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>,
	Linux-wireless <linux-wireless@vger.kernel.org>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:51869 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756625Ab2CGRhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 12:37:18 -0500
In-Reply-To: <4F579A88.6030503@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2012 09:27 AM, Felix Fietkau wrote:
> On 2012-03-07 4:24 PM, Justin P. Mattock wrote:
>> On 03/07/2012 07:19 AM, Mohammed Shafi wrote:
>>> On Wed, Mar 7, 2012 at 7:55 PM, Justin P. Mattock
>>> <justinmattock@gmail.com>   wrote:
>>>> ath9k craps out from time to time(more annoying if anything)
>>>>
>>>> [44309.840830] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44309.858246] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44309.858255] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44309.932801] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44309.950352] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44309.950361] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.024301] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.041641] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.041646] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.116316] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.133909] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.133918] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.208021] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.225752] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.225761] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.299922] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.317579] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>>>> [44310.317587] ath: Could not stop RX, we could be confusing the DMA engine
>>>> whe
>>>
>>> this is has become a know issue but less harmful, please try to see if
>>> the workaround of disabling power save helps
>>>
>>> iw dev wlanX set power_save off
>>>
>>
>> ok! I have set that on the machine.. will see if I get this message in
>> the upcoming weeks.
> Also, please try this patch with powersave enabled:
> http://nbd.name/ps-fix.patch
>
> - Felix
>

I will give that a try as well..

Thanks!

Justin P. Mattock

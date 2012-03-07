From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Wed, 07 Mar 2012 07:24:11 -0800
Message-ID: <4F577D9B.7020402@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>,
	Linux-wireless <linux-wireless@vger.kernel.org>
To: Mohammed Shafi <shafi.wireless@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:36047 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597Ab2CGPYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 10:24:16 -0500
In-Reply-To: <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2012 07:19 AM, Mohammed Shafi wrote:
> On Wed, Mar 7, 2012 at 7:55 PM, Justin P. Mattock
> <justinmattock@gmail.com>  wrote:
>> ath9k craps out from time to time(more annoying if anything)
>>
>> [44309.840830] ath: Failed to stop TX DMA, queues=0x001!
>> [44309.858246] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>> [44309.858255] ath: Could not stop RX, we could be confusing the DMA engine
>> when we start RX up
>> [44309.932801] ath: Failed to stop TX DMA, queues=0x001!
>> [44309.950352] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>> [44309.950361] ath: Could not stop RX, we could be confusing the DMA engine
>> when we start RX up
>> [44310.024301] ath: Failed to stop TX DMA, queues=0x001!
>> [44310.041641] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>> [44310.041646] ath: Could not stop RX, we could be confusing the DMA engine
>> when we start RX up
>> [44310.116316] ath: Failed to stop TX DMA, queues=0x001!
>> [44310.133909] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>> [44310.133918] ath: Could not stop RX, we could be confusing the DMA engine
>> when we start RX up
>> [44310.208021] ath: Failed to stop TX DMA, queues=0x001!
>> [44310.225752] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>> [44310.225761] ath: Could not stop RX, we could be confusing the DMA engine
>> when we start RX up
>> [44310.299922] ath: Failed to stop TX DMA, queues=0x001!
>> [44310.317579] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>> [44310.317587] ath: Could not stop RX, we could be confusing the DMA engine
>> whe
>
> this is has become a know issue but less harmful, please try to see if
> the workaround of disabling power save helps
>
> iw dev wlanX set power_save off
>

ok! I have set that on the machine.. will see if I get this message in 
the upcoming weeks.

>
>
>>
>>
>> part of dmesg here:
>> http://fpaste.org/xew6/
>> I can supply full log if needed..
>>
>> Justin P. Mattock
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>

Justin P. Mattock

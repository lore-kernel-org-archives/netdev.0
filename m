From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Wed, 07 Mar 2012 18:27:36 +0100
Message-ID: <4F579A88.6030503@openwrt.org>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F577D9B.7020402-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2012-03-07 4:24 PM, Justin P. Mattock wrote:
> On 03/07/2012 07:19 AM, Mohammed Shafi wrote:
>> On Wed, Mar 7, 2012 at 7:55 PM, Justin P. Mattock
>> <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
>>> ath9k craps out from time to time(more annoying if anything)
>>>
>>> [44309.840830] ath: Failed to stop TX DMA, queues=0x001!
>>> [44309.858246] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>> [44309.858255] ath: Could not stop RX, we could be confusing the DMA engine
>>> when we start RX up
>>> [44309.932801] ath: Failed to stop TX DMA, queues=0x001!
>>> [44309.950352] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>> [44309.950361] ath: Could not stop RX, we could be confusing the DMA engine
>>> when we start RX up
>>> [44310.024301] ath: Failed to stop TX DMA, queues=0x001!
>>> [44310.041641] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>> [44310.041646] ath: Could not stop RX, we could be confusing the DMA engine
>>> when we start RX up
>>> [44310.116316] ath: Failed to stop TX DMA, queues=0x001!
>>> [44310.133909] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>> [44310.133918] ath: Could not stop RX, we could be confusing the DMA engine
>>> when we start RX up
>>> [44310.208021] ath: Failed to stop TX DMA, queues=0x001!
>>> [44310.225752] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>> [44310.225761] ath: Could not stop RX, we could be confusing the DMA engine
>>> when we start RX up
>>> [44310.299922] ath: Failed to stop TX DMA, queues=0x001!
>>> [44310.317579] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>>> [44310.317587] ath: Could not stop RX, we could be confusing the DMA engine
>>> whe
>>
>> this is has become a know issue but less harmful, please try to see if
>> the workaround of disabling power save helps
>>
>> iw dev wlanX set power_save off
>>
> 
> ok! I have set that on the machine.. will see if I get this message in 
> the upcoming weeks.
Also, please try this patch with powersave enabled:
http://nbd.name/ps-fix.patch

- Felix
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

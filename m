From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 26 Aug 2014 16:56:01 +0200
Message-ID: <53FCA001.6090404@broadcom.com>
References: <52BDE9DC.5040206@msgid.tls.msk.ru> <52BE9CF9.7030305@broadcom.com> <52BEC2F6.7010505@msgid.tls.msk.ru> <52D4FC8B.6090301@msgid.tls.msk.ru> <52F925A9.1030707@msgid.tls.msk.ru> <53526124.6050407@msgid.tls.msk.ru> <53FC1789.6020407@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53FC1789.6020407-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/26/14 07:13, Michael Tokarev wrote:
> [Adding netdev@ to the mix.
>   Original thread, started at Dec-2013, can be found at
>    http://marc.info/?t=138817851800006&r=1&w=2 or
>    http://www.spinics.net/lists/linux-wireless/msg116502.html
> ]
>
> 19.04.2014 15:42, Michael Tokarev wrote:
>> [big skip]
>>
>>
>> Tried kernel 3.14 with this device.  Still no go, the brcmsmac driver still
>> does not work correctly, it stalls as before.
>
> Today I tried 3.16 kernel today too, just for fun (since this whole brcmsmac
> thing looks not more like a non-working toy).  Now with another laptop and
> the same broadcom wifi adaptor (BRCM4313 802.11bgn Wireless Network Adapter
> rev 01) (because due to cracked usb port on my original notebook it does not
> work anymore).
>
> This combination (kernel&  wifi) does not work at all.  Or, it is more jokish
> than before -- the NIC works for ARP packets but nothing else, not even ping
> or DNS or NTP.  I see the access point sending replies (to pings or dns), but
> these replies are not shown by tcpdump on the laptop.  Even not all ARP packets
> sent by the AP reaches the laptop.
>
> So, I'm curious -- why this driver is found in regular section of kernel?
> It looks like it should be in staging at least, or better yet, in a new section
> titled "toy drivers" or something like this.  Does it work for any device at
> all?

Hi Michael,

Thanks for your encouraging suggestions. I revisited the threads you 
referred to. In the boardflags it shows you have a bt+wifi card. It 
could be that is an issue. The brcmsmac supports other devices, ie. 
bcm43224/5 and the bcm4313 comes in a number of varieties. From what you 
tell here it seems you have trouble in rx path so I will look into that 
area if there is any specifically done for your variant of the bcm4313.

Regards,
Arend

> Thanks,
>
> /mjt

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

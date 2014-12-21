From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Dec 2014 16:03:17 +0100
Message-ID: <5496E135.1@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <141935691.MGh8oJCUVD@fuchs> <5496D59E.5030601@broadcom.com> <9234001.YBqfvtcJFx@fuchs>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	"brcm80211 development" <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:27208 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaLUPDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 10:03:20 -0500
In-Reply-To: <9234001.YBqfvtcJFx@fuchs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 15:24, Maximilian Engelhardt wrote:
> On Sunday 21 December 2014 15:13:50 Arend van Spriel wrote:
>> On 12/21/14 15:08, Maximilian Engelhardt wrote:
>>> On Sunday 21 December 2014 11:12:40 Arend van Spriel wrote:
>>>> On 12/21/14 10:58, Michael Tokarev wrote:
>>>>> 16.12.2014 19:51, Arend van Spriel wrote:
>>>>>> Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please
>>>>>> remove that call as it causes endless recursion and eventually reboot.>
>>>>>
>>>>> Ok, that was easy.  Now it loads, but wifi link still
>>>>> does not work, stalling as before.  What we're looking
>>>>> at now?
>>>>
>>>> The patch is just to provide me with extra bt-coex related information
>>>> in the kernel log. So if you can provide that to me I have to info
>>>> needed to look in the proprietary code base to determine what is missing.
>>>>
>>>> Regards,
>>>> Arend
>>>
>>> Hi Arend,
>>
>>> here is the output from my card:
>> Thanks. It shows you have have the same bt-coex version as Michael. I am
>> not familiar with bluetooth side of things. Are you both using bluetooth
>> on 4313?
>>
>> Regards,
>> Arend
>
> I don't know. I think I have Bluetooth somehow enabled but I'm not really
> using it. I definitely don't have any Bluetooth devices connected. I could try
> to unload/disable Bluetooth it to see if it makes any difference.

That would be useful to know.

Thanks,
Arend

> Greetings,
> Maxi
>

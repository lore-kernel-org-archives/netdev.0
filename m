From: Robert Martin <robertm83@gmail.com>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape
 git pull..
Date: Mon, 04 Dec 2006 18:46:35 -0500
Message-ID: <4574B35B.5070207@gmail.com>
References: <45733FBF.5020800@gmail.com>	<87y7pogj1k.fsf@briny.internal.ondioline.org>	<45745D2B.1090700@gmail.com>	<87ac231ari.fsf@briny.internal.ondioline.org>	<45746370.4070205@gmail.com> <8764cr190q.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:21431 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967907AbWLEAqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 19:46:47 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3960507wxd
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 16:46:46 -0800 (PST)
To: Robert Martin <robertm83@gmail.com>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
In-Reply-To: <8764cr190q.fsf@briny.internal.ondioline.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Collins wrote:
> (Please use reply-to-all to keep Cc:s intact, and place new material
> below quoted material.)
>
> Robert Martin <robertm83@gmail.com> writes:
>
>   
>> Paul Collins wrote:
>>     
>>> Robert Martin <robertm83@gmail.com> writes:
>>>
>>>       
>>>> Alas, that seems to have been the problem, I was getting different
>>>> frequencies.  Once I manually set the frequency, dhclient worked
>>>> perfectly.  The only problem now is that I seem to be limited to very
>>>> slow speeds (on the order of 5-20K/s, or ~120 kilobits/s).
>>>>         
>>> I guess the speed problem is due to the general state of BCM4318
>>> support, as mentioned by the developers.
>>>
>>> I'm glad the frequency thing isn't some weird glitch that only I am
>>> experiencing though.
>>>
>>>       
>> I'm pretty sure that I'm using a 4311 chip... lspci -n gives...
>>
>> 03:00.0 0280: 14e4:4311 (rev 01)
>>
>> ...I might have been mistaken about it being a PCI-E chip in that
>> case.  One additional question, it seems the link quality is very low;
>> "iwconfig wlan0" tells me it's 3/100 after associating with my AP.
>> Could that be the power issue that Johannes Berg was speaking of?  I'm
>> curious as to what speeds you're running at, and what your link
>> quality is.
>>     
>
> My card (a 4306) seems to be running at 11Mbps.  No idea how to change
> it: iwconfig doesn't report the current rate (I had to go digging in
> sysfs) and trying to change it with iwconfig fails with "Operation not
> supported".
>
> Here's the signal info:
>
>         Link Quality=228/100  Signal level=-32 dBm  Noise level=-70 dBm
>
> The machine is about 3 metres from the AP.
>
>   
A quick test just incase the information is somehow helpful... I moved 
to within two meters of my AP with nothing blocking the way--the link 
quality jumped up to 46/100 (vs 3/100 5m away and a wall blocking), 
though there was no increase in speed (still limited to ~120 kilobits/s).

Before:  Link Quality=3/100  Signal level=-73 dBm  Noise level=-66 dBm

After: Link Quality=46/100  Signal level=-49 dBm  Noise level=-69 dBm

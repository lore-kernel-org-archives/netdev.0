From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Tue, 11 Feb 2014 14:26:47 -0800
Message-ID: <CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:41498 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbaBKW0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 17:26:48 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so9544690obc.34
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 14:26:47 -0800 (PST)
In-Reply-To: <B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 6:36 PM, hayeswang <hayeswang@realtek.com> wrote:
>  Grant Grundler [mailto:grundler@google.com]
>> Sent: Tuesday, February 11, 2014 9:39 AM
>> To: Hayes Wang
>> Cc: inky.yoo@samsung.com; netdev; David Miller
>> Subject: RTL8153 fails to get link after applying c7de7dec2
>> to 3.8 kernel
>>
>> Hi Hayes,
>> "r8152: ecm and vendor modes coexist" patch prevents RTL8153 device
>> from establishing a link in the backport I've worked on for
>> chromeos-3.8 kernel. IIRC, r815x driver claims this device. Without
>> this patch, r8152 is able to establish a link with RTL8153 device.
>>
>> This was the last patch in the series of 40 patches that I
>> cherry-picked and r8152 driver seems to "basically" work WITHOUT this
>> last patch.  I've not tested much yet...but DHCP worked and I'm able
>> to run netperf tests. I've not investigated why this patch fails and
>> probably won't.
>>
>> If you have opportunity, can you confirm RTL8153 devices work for you
>> with any recent upstream kernel?
>
> I had tested the patch before I sent it, and I didn't see any problem.

Excellent - thank you! :)

> I would test the RTL8153 again with kernel 3.14-RC2.

Ok - if it worked before...I expect it will continue to work for you.

> Does it work if you unplug and plug the dangle again?

No, it didn't. Same symptom. I did try that.

Offhand, do you know of a reason I should pursue fixing this on
chromeos-3.8? (better performance or more robust?)

Right now I don't think it's worth pursuing since ChromeOS moves to
new kernels slowly but regularly and without this one patch seems to
be working.  We have a fair number of USB and USBNET backports to
support USB 3.0 devices.  So it's a bit of a mess that I really don't
want to dig into unless I have a good reason to.

As long as you are comfortable kernel.org releases are working for
you, the driver should "just work" for ChromeOS when we get to 3.14
(or later) kernels.

thanks for the help!
grant

>
> Best Regards,
> Hayes
>

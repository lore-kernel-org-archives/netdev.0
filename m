From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Wed, 26 Feb 2014 09:19:29 -0800
Message-ID: <CANEJEGtJfUsond3kowuQ24JbLdE71CGEtX4BgMDKyG2AFuiniw@mail.gmail.com>
References: <D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw>
	<CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com>
	<6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
	<20140226.115831.255949929805078536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hayes Wang <hayeswang@realtek.com>,
	Inki Yoo <inky.yoo@samsung.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:48771 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaBZRT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 12:19:29 -0500
Received: by mail-ie0-f173.google.com with SMTP id lx4so937656iec.32
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 09:19:29 -0800 (PST)
In-Reply-To: <20140226.115831.255949929805078536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 8:58 AM, David Miller <davem@davemloft.net> wrote:
> From: hayeswang <hayeswang@realtek.com>
> Date: Wed, 26 Feb 2014 18:13:00 +0800
>
>> Grant Grundler [mailto:grundler@google.com]
>>> Sent: Tuesday, February 25, 2014 12:18 AM
>>> To: hayeswang
>>> Cc: Inki Yoo; netdev
>>> Subject: Re: RTL8153 fails to get link after applying
>>> c7de7dec2 to 3.8 kernel
>> [...]
>>> Does Realtek have a publicly available tool that I can use to set all
>>> customization back to "official" values?
>>
>> Please contact with the person who give you the dangle.
>> You should need the another one.
>
> This is not an appropriate response.
>
> Your company made a chip, and people are going to repackage it and
> reuse it in their own implementations.
>
> Sometimes they will set jumpers incorrectly, add bugs to the firmware,
> and make other mistakes.
>
> When you are made explicitly awre of such situations, your driver
> should absolutely strive to handle that, rather than refuse to.

Dave,
I agree with this - but it's possible Samsung sent me prototype
devices that are not "final HW" and I sympathize with Hayes that these
handful of devices should be replaced/recycled.  Since these have
"RealTek" logo on them, I expect the HW to be final and something is
b0rked in this device's firmware.

I'll report back once I get this sorted out. I've made it clear to
contacts at both Samsung and Realtek the upstream driver needs to work
and they need to sort out why the devices I have now don't "just
work".

> It is mysterious to me when a driver author behaves in such a way that
> they seem to want their driver to work on fewer instances of their
> hardware rather than support more of them.

Well, we don't know the whole story. Samsung asked for a different USB
Vendor/Device ID and it's possible a few other things got change along
the way.

If this HW/FW was clearly production and I had a patch that made it
work, then we'd be in the situation you are describing.

thanks,
grant

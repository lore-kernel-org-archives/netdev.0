From: Juergen Kreileder <jk@blackdown.de>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Sat, 17 Jun 2006 02:05:01 +0200
Message-ID: <87bqsslk9e.fsf@blackdown.de>
References: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
	<87k67glrvl.fsf@blackdown.de> <1150494161.26368.39.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.blackdown.de ([213.239.206.42]:64404 "EHLO
	smtp.blackdown.de") by vger.kernel.org with ESMTP id S932486AbWFQAFI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 20:05:08 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1150494161.26368.39.camel@rh4> (Michael Chan's message of "Fri,
	16 Jun 2006 14:42:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> writes:

> On Fri, 2006-06-16 at 23:20 +0200, Juergen Kreileder wrote:
>> Michael Chan <mchan@broadcom.com> writes:
>>
>>>
>>> Did this use to work with an older kernel or older tg3 driver? If
>>> yes, what version?
>>
>> Works fine with 2.6.16 and earlier.
>>
>>> Please also provide the full tg3 probing output during modprobe
>>> and ifconfig up. Thanks.
>>
> Looking at the patch history since 2.6.16, the only patch that could
> have an impact is the one that enables TSO by default.
>
> Please try turning TSO off to see if it makes a difference:
>
> ethtool -K eth0 tso off

Seems to work fine with TSO disabled.


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://blog.blackdown.de/

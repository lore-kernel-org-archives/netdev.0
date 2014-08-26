From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 26 Aug 2014 20:15:31 +0400
Message-ID: <53FCB2A3.1050605@msgid.tls.msk.ru>
References: <52BDE9DC.5040206@msgid.tls.msk.ru> <52BE9CF9.7030305@broadcom.com> <52BEC2F6.7010505@msgid.tls.msk.ru> <52D4FC8B.6090301@msgid.tls.msk.ru> <52F925A9.1030707@msgid.tls.msk.ru> <53526124.6050407@msgid.tls.msk.ru> <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:37617 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbaHZQPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:15:34 -0400
In-Reply-To: <53FCA001.6090404@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

26.08.2014 18:56, Arend van Spriel wrote:
> On 08/26/14 07:13, Michael Tokarev wrote:
[]
>> So, I'm curious -- why this driver is found in regular section of kernel?
>> It looks like it should be in staging at least, or better yet, in a new section
>> titled "toy drivers" or something like this.  Does it work for any device at
>> all?
> 
> Hi Michael,
> 
> Thanks for your encouraging suggestions.

You might be a good politician :)  These are blames, quite strong...

Seriously. As you revisited this thread, I had quite some issues and
money loss after all this, -- after initially especially choosing a
model with a supported wifi card which turned out to be non-working,
which I tried to fix by buying a new wifi NIC (which didn't work
thanks to Lenovo), and which I finally broke due to usb wifi dongle
I used.

But that's all "poetry", the main source of my blames is you reaction -
your first reply was really ecoraging, I hoped we can have some solution
together (I have strong programming background, just not as good with
kernel and drivers as you).  But after your single reply, you never
spoke again until now.  That's 8 months.  _That_ is where my frustration
comes from.

And the actual facts are true - by now I have had 2 entirely different
devices (my original laptop which is now thrown away and another, given
by me by a friend because I needed something) - I dunno if that's
exactly the same wifi card or not (lspci output looks similar, and
this one is also bt/wifi combo), but they both doesn't work in a
quite similar way.  So, the driver doesn't work with 2 out of 2 devices
which I've seen.  Not a good statistics generally, but that's 100%
"hit" ratio for me.  So I really am curious if this driver works at
all.

>    I revisited the threads you referred to. In the boardflags it shows you
> have a bt+wifi card. It could be that is an issue. The brcmsmac supports other
> devices, ie. bcm43224/5 and the bcm4313 comes in a number of varieties.
> From what you tell here it seems you have trouble in rx path so I will look
> into that area if there is any specifically done for your variant of the bcm4313.

I tested this "new" laptop with 3.16 kernel just briefly.  I may try more
complete analysis.  I can participate with the debugging/dumping (I already
mentioned my strong programming background - but I'm really not into drivers
and hardware internals).  So, basically, I'm all yours ;)  Not that I really
need this driver anymore (since I will avoid these cards like a plague, for
obvious reasons :), but I want to have some good outcome out of all this
story :)

Thanks,

/mjt

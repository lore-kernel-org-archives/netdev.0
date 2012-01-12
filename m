From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 09:31:12 -0800
Message-ID: <CA+55aFzeCjEn4MmLmpxvUnCFPUYjY9mG+=MyVEJtdC0enR_qEQ@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <4F0EDC75.3040003@broadcom.com> <4F0F15E6.30301@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62746 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab2ALRbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 12:31:33 -0500
Received: by ghbg16 with SMTP id g16so413231ghb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 09:31:33 -0800 (PST)
In-Reply-To: <4F0F15E6.30301@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 9:18 AM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>
> For completeness, sromctrl is 0x12, thus bit 1 (SRC_PRESENT) is not set, and
> my device has an OTP, not an SPROM.

So this is again something that apple is *famous* for.

They try to control their hardware very tightly, and OS X will (for
example) not use non-apple wireless cards as "Airport" cards, and will
do things like dropping features ("Oh, you tried to save money by
buying a generic wireless minipci card instead of the apple branded
one? Well, that's fine, but now I'll make your network flaky and will
refuse to support 802.11n just to make a point.").

Never mind that the hardware is the same - they'll literally look at
the PCI subvendor ID and things like that, and if it doesn't say
"Apple", they will simply not enable all the features, or won't even
connect to it.

They've done this forever. Others do it too (I think both HP and IBM
have done the exact same thing with minipci wireless cards - back when
WiFi used to be a "premium" thing in a laptop, and vendors charged
quite a bit extra for it, gah!). But Apple does it for a *lot* of
things, presumably because they want to make it extra hard for clone
makers (or just tinkerers that would try to run OS X on a regular PC
that just happened to have the exact same hardware as a Macbook).

Seriously. I really like my Macbook Air hardware, but the moment some
non-apple supplier makes anything comparable, I'll drop it like the
crap it is. Exactly because Apple uses software to make it harder to
use. Installing Linux on that thing is "interesting" - Linux works
perfectly fine on it, but with all the special Apple firmware crap,
you have to jump through hoops.

> I do not see anything wrong with commit 888153b3db3f, but I realize that my
> card really does not test any of those changes.

I suspect the big change is the version check and the size of the
sprom image. Apple probably has an older version. I assume that the
subvendor ID etc comes from the srom?

                            Linus

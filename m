From: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 2/2] Using LP firmware for taking advantage of the
 low-power capabilities.
Date: Wed, 19 Sep 2012 20:54:01 +0200
Message-ID: <CAOjsGA25PR9OCC_cAVn=gztk9YB6pNxCz=1mFjDxxQoc-tofEw@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
 <1348053493-22955-2-git-send-email-jarl@softace.dk> <5059DFF1.4060405@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	=?UTF-8?Q?G=C3=A1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5059DFF1.4060405-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for feed back.

2012/9/19 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>:
>
>
> I have some questions about this patch. Where did you get the information
> needed to make these changes?

To be completely honest: I didn't get any information, it is based
purely on practical experiments: I experienced some inconsistency wrt.
performance on my hp6735b. I had some time to look at the driver (it's
15 years since I patched the kernel last time). Anyway I saw the
filename pattern for firmware and saw that `b43-fwcutter
broadcom-wl-5.100.138/linux/wl_apsta.o -w` contained similar files
ending on "16". So I simple tried it out (for version 16), and so far
it seems to work better. It also seems to wake up faster after a
sleep.

> Did it come from reverse engineering some
> Broadcom code

No!

> or did you look at their actual code?

No!

> There is a great deal
> of difference relative to our "clean-room" status. Anyone that has seen
> non-GPL Broadcom material cannot contribute code to b43.

I have not seen any Broadcom code at all (apart from the stuff that is
already in the linux source tree)

>
> Have you tested this code on devices with rev>=16?

Yes on my HP6735b having this chip integrated:
[ 1577.549270] b43-phy1: Broadcom 4322 WLAN found (core revision 16)
[ 1577.592117] b43-phy1 debug: Found PHY: Analog 8, Type 4, Revision 4
[ 1577.592158] b43-phy1 debug: Found Radio: Manuf 0x17F, Version
0x2056, Revision 3

I guess the part of the patch for PHY_LP has not been reached. I will
submit a new series of patches that separates things

>
> Now for some comments: This patch also needs the "b43:" added to the
> subject.

Sorry. It's long ago I have submitted patches to the kernel.

> In addition, you appear to have at least one white-space error in
> the MODULE_FIRMWARE line.

I am not sure what you mean here. Is this a mail issue... (I wrote it
just like the other ones around it)

> Is the addition of your copyright to the driver
> warranted by this change?

As far as I understand the copyright law: Yes, but I'm not an expert.
Neither am I 100% sure what you mean.

> For example, I have made much larger contributions
> to b43 over the years before I started doing reverse-engineering on this
> driver, but I never added my copyright.

I suggest you do.

> Your "Signed-off-by" implies
> copyright for the patch.

The fact that I authored the patch implies copyright (even without
Signed-off-by)


Jarl
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

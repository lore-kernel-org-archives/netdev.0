From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] ath: wil6210: Fix build error
Date: Sun, 21 Jul 2013 19:55:34 +0300
Message-ID: <87bo5vyhrt.fsf@purkki.adurom.net>
References: <1374374808-12768-1-git-send-email-Larry.Finger@lwfinger.net>
	<51EBFABB.8080701@lwfinger.net> <1559869.yu0fjJXVeX@balsa>
	<5330916.8NnOO4SNAp@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <thomas-T/OQ2aoscs6U4IzBdx3r/Q@public.gmane.org>, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5330916.8NnOO4SNAp@lx-vladimir> (Vladimir Kondratiev's message
	of "Sun, 21 Jul 2013 18:52:38 +0300")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Dropping stable)

Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> writes:

>> It also looked like that that driver or section of the kernel was compiling 
>> with -Werror. I haven't verrified that but I remember seeing "treating all 
>> warnings as errors" at one point.
>> 
> You are right, I have this in Makefile:
> (if one turn on extra warnings with -W, there will be lots of false alarms,
> that's why this ifeq())
>
> ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
> 	subdir-ccflags-y += -Werror
> endif

This is exactly why it's recommended not to use -Werror on releases.
It's ok when developers use it, but for end users -Werror should not be
enabled by default.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

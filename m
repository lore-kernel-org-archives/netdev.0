From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Fri, 9 Jan 2009 23:29:35 +0100
Message-ID: <5a4c581d0901091429i5f3ec4ffw98e404fc1de0b198@mail.gmail.com>
References: <5a4c581d0901081233y6b546167sbe3ed9f2ea37f1f9@mail.gmail.com>
	 <20090108.125331.03608787.davem@davemloft.net>
	 <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
	 <20090109.140422.60087297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:38374 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250AbZAIW3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 17:29:37 -0500
In-Reply-To: <20090109.140422.60087297.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2009 at 11:04 PM, David Miller <davem@davemloft.net> wrote:
> From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
> Date: Fri, 9 Jan 2009 18:30:40 +0100
>
>> Clearly the requirement changed in -git8, AFAICS.
>
> Because -git8 is where the firmware requirement got added.

OK, thanks.

> If you build the TG3 driver statically into your kernel,
> the only way to get the firmware properly loaded is to
> enable that CONFIG_FIRMWARE_IN_KERNEL option.
>
> Your filesystem isn't mounted when the driver initializes
> in that case, therefore there is no way to get at the
> firwware that might be present there.

And indeed I do build tg3 in-kernel. But since the config
 option was present previously, perhaps it would have
 been the case to change the help text for tg3 explaining
 that now a non-modular build requires an extra step ?

Or maybe kbuild allows to select FIRMWARE_IN_KERNEL
 if tg3 is built non-modular ?

My only observation is that a make oldconfig shouldn't
 change a working setup to a non-working one (though
 it already happened once to me in a couple of weeks,
 the other being I915 DRM being silently skipped as a
 consequence of becoming dependent on CONFIG_FB)
 with a new kernel patch.

Clearly, if there is no easy way to avoid such a situation,
 it's okay - LKML and the other Linux-related lists are
 always helpful.

Thanks again, ciao,

--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")

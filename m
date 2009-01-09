From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Fri, 9 Jan 2009 18:30:40 +0100
Message-ID: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
References: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
	 <3f9a31f40901072212x41e405fh7e36f6adb927814b@mail.gmail.com>
	 <5a4c581d0901081233y6b546167sbe3ed9f2ea37f1f9@mail.gmail.com>
	 <20090108.125331.03608787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:38349 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbZAIRan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 12:30:43 -0500
In-Reply-To: <20090108.125331.03608787.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2009 at 9:53 PM, David Miller <davem@davemloft.net> wrote:
> From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
> Date: Thu, 8 Jan 2009 21:33:35 +0100
>
>> On Thu, Jan 8, 2009 at 7:12 AM, Jaswinder Singh Rajput
>> <jaswinderlinux@gmail.com> wrote:
>> > Hello alessandro,
>> >
>> > On Wed, Jan 7, 2009 at 7:54 PM, Alessandro Suardi
>> > <alessandro.suardi@gmail.com> wrote:
>> >>
>> >> Note that I don't have CONFIG_FIRMWARE_IN_KERNEL, but on
>> >>  the other hand I didn't earlier, either... and yes, CONFIG_MODULES=y.
>> >>
>> >
>> > Please try with CONFIG_FIRMWARE_IN_KERNEL , is this makes some difference.
>>
>> Yes it does, thank you - 2.6.28-git11 with CONFIG_FIRMWARE_IN_KERNEL
>>  gets my tg3 back to work on boot. Must be a requirement since -git8 then ?
>
> It is if you don't have the tg3 firmware files in your filesystem
> already.

As I mentioned in the original email to LKML about -git8, and in
 the first CC to netdev about -git10, I appear to have these files
 in /lib/firmware/tigon. I save every single .config file I used in the
 last, what, four years ?

.config-2.6.28-git10:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git11:CONFIG_FIRMWARE_IN_KERNEL=y
.config-2.6.28-git2:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git3:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git4:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git5:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git6:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git7:# CONFIG_FIRMWARE_IN_KERNEL is not set
.config-2.6.28-git8:# CONFIG_FIRMWARE_IN_KERNEL is not set

-git-2 through -git-7 work
-git8 and -git10 don't work
-git11 works

Clearly the requirement changed in -git8, AFAICS.

thanks,

--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")

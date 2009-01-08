From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Thu, 8 Jan 2009 21:33:35 +0100
Message-ID: <5a4c581d0901081233y6b546167sbe3ed9f2ea37f1f9@mail.gmail.com>
References: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
	 <3f9a31f40901072212x41e405fh7e36f6adb927814b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David Woodhouse" <dwmw2@infradead.org>
To: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762080AbZAHUdy@vger.kernel.org>
In-Reply-To: <3f9a31f40901072212x41e405fh7e36f6adb927814b@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 8, 2009 at 7:12 AM, Jaswinder Singh Rajput
<jaswinderlinux@gmail.com> wrote:
> Hello alessandro,
>
> On Wed, Jan 7, 2009 at 7:54 PM, Alessandro Suardi
> <alessandro.suardi@gmail.com> wrote:
>>
>> Note that I don't have CONFIG_FIRMWARE_IN_KERNEL, but on
>>  the other hand I didn't earlier, either... and yes, CONFIG_MODULES=y.
>>
>
> Please try with CONFIG_FIRMWARE_IN_KERNEL , is this makes some difference.

Yes it does, thank you - 2.6.28-git11 with CONFIG_FIRMWARE_IN_KERNEL
 gets my tg3 back to work on boot. Must be a requirement since -git8 then ?

Thanks again, ciao,

--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")

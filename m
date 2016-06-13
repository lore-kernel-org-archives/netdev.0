From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED trigger
Date: Mon, 13 Jun 2016 17:10:02 -0400
Message-ID: <CA+A7VXWdt16KHNx0n9jnpimCvN9dV38kb6smTbGWaJYo5VYcOQ@mail.gmail.com>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
 <1462199948-6424-2-git-send-email-jprvita@endlessm.com> <20160504072936.GB17045@amd>
 <1463045572.13313.21.camel@sipsolutions.net> <20160519071639.GB17077@amd>
 <1465476194.3442.21.camel@sipsolutions.net> <CA+A7VXXP3TYuk4Vvgc8YvxPFo06GG6WpyLJS+2vMLzr0iKQgsA@mail.gmail.com>
 <20160613190048.GA17101@amd> <CA+A7VXXOfN1Td2T6uiunWZMS4gvS5sHDzPiDp9VEdx+OPJpSmA@mail.gmail.com>
 <20160613210109.GA9303@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34975 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161278AbcFMVKn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:10:43 -0400
In-Reply-To: <20160613210109.GA9303@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 June 2016 at 17:01, Pavel Machek <pavel@ucw.cz> wrote:
> On Mon 2016-06-13 15:59:35, Jo=C3=A3o Paulo Rechi Vita wrote:
>> On 13 June 2016 at 15:00, Pavel Machek <pavel@ucw.cz> wrote:
>> > Hi!
>> >
>> >> > Jo=C3=A3o, that means you should send a patch to add the ::rfki=
ll suffix.
>> >> >
>> >>
>> >> IMO "airplane" (or maybe "airplane-mode") is a better suffix, as =
it
>> >> reflects the label on the machine's chassis. I'll name it
>> >> "asus-wireless::airplane" and send this through platform-drivers-=
x86,
>> >> as this is now contained in the platform-drivers-x86 subsystem. T=
hanks
>> >> Johannes for your patience and help designing and reviewing the r=
fkill
>> >> changes, even if not all of them made it through in the end. And
>> >> thanks everyone else involved for the feedback.
>> >
>> > Actually, I'd do '::rfkill', for consistency with other places in
>> > /sys.
>> >
>> > /sys/devices/platform/thinkpad_acpi/rfkill/rfkill1/name
>> > /sys/class/rfkill
>> > /sys/module/rfkill
>> >
>>
>> If we use "rfkill" as a suffix, how do you expect userspace to be ab=
le
>> to differentiate between a LED that indicates airplane-mode (LED ON
>> when all radios are OFF) and a LED that indicates the state of a
>> specific radio like WiFi or Bluetooth (LED ON when that specific rad=
io
>> is ON)? If we're going this route we should provide meaningful
>> information here.
>
> '::airplane' has same problem, no?
>

No, because in this case we would not use "airplane" as a suffix for a
LED associated with an individual radio.

> If you want to distinguish that, maybe you can do '::rfkill' for
> everything vs '::rfkill-wifi' for wifi-only and '::rfkill-bt' for
> bluetooth...
>

The problem here is that the "rfkill" name is already associated with
individual rfkill switches under /sys/class/rfkill,
/sys/devices/platform/*/rfkill etc, so I think we're better off
distinguishing "airplane" vs "wifi" vs "bluetooth" etc, to avoid
confusion.

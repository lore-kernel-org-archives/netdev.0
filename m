From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED trigger
Date: Mon, 13 Jun 2016 11:24:24 -0400
Message-ID: <CA+A7VXXP3TYuk4Vvgc8YvxPFo06GG6WpyLJS+2vMLzr0iKQgsA@mail.gmail.com>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
 <1462199948-6424-2-git-send-email-jprvita@endlessm.com> <20160504072936.GB17045@amd>
 <1463045572.13313.21.camel@sipsolutions.net> <20160519071639.GB17077@amd> <1465476194.3442.21.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1465476194.3442.21.camel@sipsolutions.net>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9 June 2016 at 08:43, Johannes Berg <johannes@sipsolutions.net> wrot=
e:
> On Thu, 2016-05-19 at 09:16 +0200, Pavel Machek wrote:
>

(...)

>> LED
>> subsystem seems to use suffix of LED name to do that. So if we
>> standartize, lets say "::rfkill" suffix for this, it should work and
>> follow existing practice.
> [...]
>> There is one -- suffix in the LED name.
>
> I don't really think that's a good way, and it doesn't seem to be use=
d
> universally, but I suppose it's good enough.
>

The main practical drawback of this approach IMO is that we can't
guarantee that userspace processes will not step on each other's toes
trying to control the LED concurrently. But I guess that is something
that userspace will have to solve for now, I rather get this moving
without the trigger than not moving at all.

> Jo=C3=A3o, that means you should send a patch to add the ::rfkill suf=
fix.
>

IMO "airplane" (or maybe "airplane-mode") is a better suffix, as it
reflects the label on the machine's chassis. I'll name it
"asus-wireless::airplane" and send this through platform-drivers-x86,
as this is now contained in the platform-drivers-x86 subsystem. Thanks
Johannes for your patience and help designing and reviewing the rfkill
changes, even if not all of them made it through in the end. And
thanks everyone else involved for the feedback.

Best regards,

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita

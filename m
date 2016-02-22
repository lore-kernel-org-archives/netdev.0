From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 7/9] rfkill: Create "rfkill-airplane_mode" LED trigger
Date: Mon, 22 Feb 2016 11:10:50 -0500
Message-ID: <CA+A7VXUJNUftsQjEAGtOmQbCMF1WzRJVAMqF2NDPYoitmXTrrQ@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-8-git-send-email-jprvita@endlessm.com> <1455826121.2084.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1455826121.2084.17.camel@sipsolutions.net>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 February 2016 at 15:08, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> On Mon, 2016-02-08 at 10:41 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>> This creates a new LED trigger to be used by platform drivers as a
>> default trigger for airplane-mode indicator LEDs.
>>
>> By default this trigger will fire when RFKILL_OP_CHANGE_ALL is calle=
d
>> for all types (RFKILL_TYPE_ALL), setting the LED brightness to
>> LED_FULL
>> when the changing the state to blocked, and to LED_OFF when the
>> changing
>> the state to unblocked. In the future there will be a mechanism for
>> userspace to override the default policy, so it can implement its
>> own.
>>
>> This trigger will be used by the asus-wireless x86 platform driver.
>
> Just one comment - I think you should be consistent with the _ vs - a=
nd
> just use "rfkill-airplane-mode" as the name.
>

Ok, no problem. I'll change for the next version.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita

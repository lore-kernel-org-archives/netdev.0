From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 3/4] net/rfkill: Create "airplane mode" LED trigger
Date: Fri, 18 Dec 2015 19:36:34 -0500
Message-ID: <CA+A7VXXyWjQOo0TVsRmw-PA8U6e1Jo_bx1HcO8a+CWu=gHcxDw@mail.gmail.com>
References: <1450193442-7930-1-git-send-email-jprvita@endlessm.com>
 <1450193442-7930-4-git-send-email-jprvita@endlessm.com> <20151219002212.GC7244@malice.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Corentin Chary <corentin.chary@gmail.com>,
	platform-driver-x86@vger.kernel.org,
	acpi4asus-user@lists.sourceforge.net,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: Darren Hart <dvhart@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33672 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbLSAhP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 19:37:15 -0500
In-Reply-To: <20151219002212.GC7244@malice.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 December 2015 at 19:22, Darren Hart <dvhart@infradead.org> wrote:
> On Tue, Dec 15, 2015 at 10:30:41AM -0500, Jo=C3=A3o Paulo Rechi Vita =
wrote:
>> For platform drivers to be able to correctly drive the "Airplane Mod=
e"
>> indicative LED there needs to be a RFKill LED trigger tied to the gl=
obal
>> state of RFKILL_TYPE_ALL (instead of to a specific RFKill) and that
>> works in an inverted manner of regular RFKill LED triggers, that is,=
 the
>> LED is ON when the state is blocked, and OFF otherwise.
>>
>> This commit implements such a trigger, which will be used by the
>> asus-wrc x86 platform driver.
>
> So this will need to go through Johannes and David per get_maintainer=
=2Epl before
> we can use it in platform drivers.
>

Yes, I am aware of that. I just wanted to get feedback and validate
the new platform driver that makes use of this new RFKill LED trigger
before proposing it, since I expect that will be their first
questioning.

=46or those who were not in the original message, this is patch is part
of a series implementing a new platform driver for the airplane mode
hotkey and LED present in some Asus laptops, which is a separate ACPI
device (not part of WMI) with ACPI _HID "ASHS" and named "Wireless
Radio Control" by Asus.

Thanks for your feedback!

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita

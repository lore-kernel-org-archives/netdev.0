From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: RE: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 21:16:46 +0100
Message-ID: <f47edcc4-cda9-4349-9590-ee8572b139ca@email.android.com>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no> <20130121.142242.2240250911008731906.davem@davemloft.net> <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D99@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"gsuarez@smithmicro.com" <gsuarez@smithmicro.com>,
	"oneukum@suse.de" <oneukum@suse.de>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43071 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847Ab3AUURv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 15:17:51 -0500
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D99@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey ORISHKO <alexey.orishko@stericsson.com> wrote:

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Monday, January 21, 2013 8:23 PM
>> To: bjorn@mork.no
>> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org;
>> gsuarez@smithmicro.com; Alexey ORISHKO; oneukum@suse.de
>> Subject: Re: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
>>=20
>> From: Bj=C3=B8rn Mork <bjorn@mork.no>
>> Date: Mon, 21 Jan 2013 16:50:37 +0100
>>=20
>> > The 2 first patches in this series are required to make the Sierra
>> > Wireless MC7710 card work in MBIM mode.  They may also be required
>> for
>> > other Qualcomm firmware based MBIM devices.
>> >
>> > Patch #1 was previously posted as a standalone patch.  This versio=
n
>> is
>> > a replacement, removing a theoretical NULL pointer exception.
>> >
>> > Patch #3 fixes a bug I introduced in v3.7
>>=20
>> All applied, thanks.
>
>Hi David,
>
>It was way too fast... I don't think we concluded on patch#2 since it
>will damage existing devices :-(

Yes, that was even faster than expected. But it's no problem really. I'=
ll prepare a fixup patch reducing it to be device specific.=20

There are still a couple of questions I am wondering about though. The =
most important one: what is Windows 8 doing different from us? Does any=
one know? I do not have a Windows 8 system myself and I wouldn't know h=
ow to snoop on it either.=20


Bj=C3=B8rn

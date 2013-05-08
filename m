From: dag dg <dagofthedofg@gmail.com>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel
 E371) WWAN card
Date: Wed, 8 May 2013 14:27:37 -0500
Message-ID: <CAO2Qn5kRZ+Cmnavw_8NKPw48NPw_9-bBAtOgWeopAB=EgzqNLw@mail.gmail.com>
References: <87li7r6bx1.fsf@nemi.mork.no> <20130508.120850.755474428060131481.davem@davemloft.net>
 <CAO2Qn5myQRhscszx0WRX588EP5NzPZuOsr1mrH3p4yDna8YP-w@mail.gmail.com>
 <20130508.121922.553557463648781118.davem@davemloft.net> <1368041150.1664.22.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Network Development <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:65527 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab3EHT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 15:27:59 -0400
In-Reply-To: <1368041150.1664.22.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cool, just wanted to make sure. When I set up a startup script to load
up the option driver I freaked when my machine locked up. Good to know
you have this covered, looking forward to seeing it implemented down
the road. Thanks.

On Wed, May 8, 2013 at 2:25 PM, Dan Williams <dcbw@redhat.com> wrote:
> On Wed, 2013-05-08 at 12:19 -0700, David Miller wrote:
>> From: dag dg <dagofthedofg@gmail.com>
>> Date: Wed, 8 May 2013 14:11:48 -0500
>>
>> > Just a side note on this. By default for this device, modprobe won't
>> > load and assign the option driver. However, if cdc_ether is
>> > blacklisted and you try to load option onto the device, it will try to
>> > load the option driver onto where cdc_ether was being used, which will
>> > cause the system to lock up. I'm not sure what needs to be done to
>> > force qmi_wwan to take over cdc_ether without option grabbing these
>> > IDs...
>
> This is a consequence of "new_id" not being flexible enough to handle
> class/subclass/protocol in addition to USB IDs.  Thus when you use it,
> the driver binds to *all* USB interfaces, even ones that the driver
> shouldn't ever control
>
> So the issue you refer to is actually user error, helped by a
> too-coarse-grained kernel API.  It's not an issue when things are all
> done correctly, which is to say when the USB IDs and interface
> class/subclass/protocol are properly added to the kernel drivers.
>
> The option patch I posted earlier will fix this issue correctly.
>
> Dan
>
>

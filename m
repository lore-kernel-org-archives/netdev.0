From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 5/8] rfkill: Remove obsolete "state" sysfs interface
Date: Tue, 19 Jan 2016 15:36:29 -0500
Message-ID: <CA+A7VXVOYY4vzYupsoG0A9kinBvRhrD3_MP2DByR5v+5gGYuyA@mail.gmail.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
 <1453218163-31998-6-git-send-email-jprvita@endlessm.com> <1453234505.23600.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	linux@endlessm.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:32794 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932734AbcASUhK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 15:37:10 -0500
In-Reply-To: <1453234505.23600.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 January 2016 at 15:15, Johannes Berg <johannes@sipsolutions.net> =
wrote:
> On Tue, 2016-01-19 at 10:42 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>> This was schedule to be removed in 2014 by:
>
>> -For details to this subsystem look at Documentation/rfkill.txt.
>> -
>> -What:                /sys/class/rfkill/rfkill[0-9]+/state
>> -Date:                09-Jul-2007
>> -KernelVersion        v2.6.22
>> -Contact:     linux-wireless@vger.kernel.org
>> -Description:         Current state of the transmitter.
>> -             This file is deprecated and scheduled to be removed
>> in 2014,
>> -             because its not possible to express the 'soft and
>> hard block'
>> -             state of the rfkill driver.
>> -Values:      A numeric value.
>> -             0: RFKILL_STATE_SOFT_BLOCKED
>> -                     transmitter is turned off by software
>> -             1: RFKILL_STATE_UNBLOCKED
>> -                     transmitter is (potentially) active
>> -             2: RFKILL_STATE_HARD_BLOCKED
>> -                     transmitter is forced off by something
>> outside of
>> -                     the driver's control.
>
> I suspect that nevertheless, we can't just remove it - Googling aroun=
d
> shows quite a bit of (e.g. Android) code using it.
>

Should I update the expected removal date to 2018, or some other time
in the future? Or if this is not going to be removed at all, shouldn't
it be moved back to stable?

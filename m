From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [REGRESSION, PATCH] sky2 WOL fix
Date: Fri, 17 Feb 2012 19:21:53 +0100
Message-ID: <4F3E9AC1.6060704@t-online.de>
References: <4F3A1A5E.9090803@t-online.de> <20120215091622.429fe9c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dilieto@lineone.net,
	Mirko Lindner <mlindner@syskonnect.de>,
	Ralph Roesler <rroesler@syskonnect.de>, arekm@maven.pl,
	nitro@legroom.net, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout11.t-online.de ([194.25.134.85]:39504 "EHLO
	mailout11.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084Ab2BQSWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 13:22:00 -0500
In-Reply-To: <20120215091622.429fe9c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.02.2012 18:16, schrieb Stephen Hemminger:
> On Tue, 14 Feb 2012 09:25:02 +0100
> Knut Petersen<Knut_Petersen@t-online.de>  wrote:
>
>>  From f3a7086638b0ee1f9d9e9028a188d96646671088 Mon Sep 17 00:00:00 2=
001
>> From: Knut Petersen<Knut_Petersen@t-online.de>
>> Date: Tue, 14 Feb 2012 08:35:17 +0100
>> Subject: [PATCH] Fix an old sky2 WOL regression
>>
>> Wake-On-Lan was broken for a few systems with commit
>> 87b09f1f25cd1e01d7c50bf423c7fe33027d7511 more than a
>> year ago.
>>
>> This commit fixes the regression for the AOpen i915GMm-HFS
>> motherboard. It reintroduces the old code, but that code is
>> only executed for those system included in a dmi_system_id
>> list. Currently there is only one entry in that list, but
>> it probably will grow.
>>
>> Signed-off-by: Knut Petersen<Knut_Petersen@t-online.de>
> You might also want to check with AOpen to see if there is a BIOS
> update. Often the BIOS programs bits on the onboard card to deal
> with power management issues.
>

[I added some people to the cc list that commented on bug #19492]

The last BIOS AOpen published for that board is more than six years old=
=2E
No. I will not bother them with this problem.

Your commit broke existing support for WOL on a number of boards.
This is known to you and to bugzilla.kernel org since 2010.  A number o=
f
people complained about that, but nothing happened.

Neither your original commit description nor the description of the
PXE_LegNat_Sel I found at other places indicate that setting
PXE_LegNat_Sel could do any harm.

Stephen: It=B4s a real regression, the fix is known. If you do not want
to go back to setting PXE_LegNat_Sel, you really should allow
dmi_matched fixes.

Mirko, Ralph: Any comments from Marvell?

cu,
  Knut

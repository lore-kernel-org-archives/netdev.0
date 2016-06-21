From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Tue, 21 Jun 2016 08:46:00 -0700
Message-ID: <13338.1466523960@famine>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com> <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com> <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com> <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:32958 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbcFUQFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:05:17 -0400
In-reply-to: <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

>2016-06-20 17:11 GMT+03:00 zhuyj <zyjzyj2000@gmail.com>:
>> 5. Switch Configuration
>> =======================
>>
>>         For this section, "switch" refers to whatever system the
>> bonded devices are directly connected to (i.e., where the other end of
>> the cable plugs into).  This may be an actual dedicated switch device,
>> or it may be another regular system (e.g., another computer running
>> Linux),
>>
>>         The active-backup, balance-tlb and balance-alb modes do not
>> require any specific configuration of the switch.
>>
>>         The 802.3ad mode requires that the switch have the appropriate
>> ports configured as an 802.3ad aggregation.  The precise method used
>> to configure this varies from switch to switch, but, for example, a
>> Cisco 3550 series switch requires that the appropriate ports first be
>> grouped together in a single etherchannel instance, then that
>> etherchannel is set to mode "lacp" to enable 802.3ad (instead of
>> standard EtherChannel).
>
>The ports are configured in switch settings (HP Procurve 2530-48G) in
>same trunk group (TrkX) and trunk group type is set as LACP.
>/proc/net/bonding/bond0 also shows that the three ports belong to same
>aggregator and bandwidth tests also support this. In my understanding
>Procurve's trunk group is pretty much the same as etherchannel in
>Cisco's terminology. The bonded link comes always up properly, but
>handling of links going down is the problem. Are there known
>differences between different vendors there?

	I did the original LACP reselection testing on a Cisco switch,
but I have an HP 2530 now; I'll test it later today or tomorrow and see
if it behaves properly, and whether your proposed patch is needed.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com

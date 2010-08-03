From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 PATCH] e1000e: 82577/82578 PHY register access issues
Date: Mon, 2 Aug 2010 18:04:43 -0700
Message-ID: <AANLkTi=P_+3wpmAA5+eqaWoGE39OkZPFhRXEuXGypAco@mail.gmail.com>
References: <20100727222808.25500.11033.stgit@localhost.localdomain>
	<20100727.210642.137855605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52338 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747Ab0HCBEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 21:04:45 -0400
Received: by iwn7 with SMTP id 7so4603912iwn.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 18:04:44 -0700 (PDT)
In-Reply-To: <20100727.210642.137855605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 21:06, David Miller <davem@davemloft.net> wrote=
:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 27 Jul 2010 15:28:46 -0700
>
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> The MAC-PHY interconnect on 82577/82578 uses a power management feat=
ure
>> (called K1) which must be disabled when in 1Gbps due to a hardware i=
ssue on
>> these parts. =C2=A0The #define bit setting used to enable/disable K1=
 is
>> incorrect and can cause PHY register accesses to stop working altoge=
ther
>> until the next device reset. =C2=A0This patch sets the register corr=
ectly.
>>
>> This issue is present in kernels since 2.6.32.
>>
>> CC: stable@kernel.org
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> Applied, thanks.
> --

Dave,
Have you sync'd up your net-next-2.6 tree with net-2.6 tree?  Because
I do not see this change in the net-next-2.6 tree.

--=20
Cheers,
Jeff

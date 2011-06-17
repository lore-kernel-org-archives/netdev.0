From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Fri, 17 Jun 2011 13:48:03 -0700
Message-ID: <4DFBBD83.9040300@candelatech.com>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com> <BANLkTikiNT1F39XaMFWc67OuP=StmntL=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49272 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757273Ab1FQUsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:48:07 -0400
In-Reply-To: <BANLkTikiNT1F39XaMFWc67OuP=StmntL=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2011 01:00 PM, Micha=B3 Miros=B3aw wrote:
> 2011/6/17<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This series provides ethtool support to set and get the rx-checksum
>> flag, and adds support to the e100 driver.
> [...]
>
> If you want to test the new features approach, you can shave top bit
> off NETIF_F_GSO_MASK (there are two unused bits there). The
> introducing patch will be +2 lines (+1 dev.c, +1 ethtool.c),
> implementation in e100: 20 lines less than patch you sent, ethtool
> userspace changes: none (assuming
> http://patchwork.ozlabs.org/patch/96374/ or equivalent applied).

Well, is that patch going in?

How do we get more bits if we need more than two?  Totally new
API?

Thanks,
Ben

>
> Best Regards,
> Micha=B3 Miros=B3aw


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


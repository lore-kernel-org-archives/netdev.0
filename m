From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Thu, 24 Sep 2009 12:10:45 -0700
Message-ID: <9929d2390909241210o6f0a640bi842307b5742c0699@mail.gmail.com>
References: <4ABAA2D0.4030608@candelatech.com>
	 <1253816908.3153.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:48533 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691AbZIXTKl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:10:41 -0400
Received: by pxi27 with SMTP id 27so2038215pxi.22
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 12:10:45 -0700 (PDT)
In-Reply-To: <1253816908.3153.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2009 at 11:28, Peter P Waskiewicz Jr
<peter.p.waskiewicz.jr@intel.com> wrote:
> On Wed, 2009-09-23 at 15:36 -0700, Ben Greear wrote:
>> When LRO is enabled, the received packet and byte counters represent=
 the
>> LRO'd packets, not the packets/bytes on the wire. =C2=A0The Intel 82=
599 NIC has
>> registers that keep count of the physical packets. =C2=A0Add these c=
ounters to
>> the ethtool stats. =C2=A0The byte counters are 36-bit, but the high =
4 bits were
>> being ignored in the 2.6.31 ixgbe driver: =C2=A0Read those as well t=
o allow
>> longer time between polling the stats to detect wraps.
>>
>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>>
>>
>> Please do not apply this until the ixgbe authors ACK it. =C2=A0There=
 may
>> have been reasons for not reading the high 4 bits, or they may disli=
ke
>> this approach entirely.
>
> Aside from the trivial line-wrap on the comments, I'm fine with this
> patch. =C2=A0There is no issue I could find with the hardware that wo=
uld
> limit you from reading the high 4 bits. =C2=A0And since we're reading=
 it
> already to clear the register, we might as well use the value we get
> from it.
>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>

I have added this patch to my tree and will push along with my other
ixgbe patches to dave/netdev.  Thanks.

--=20
Cheers,
Jeff

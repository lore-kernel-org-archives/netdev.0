From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Mon, 11 Jul 2011 19:33:59 -0700 (PDT)
Message-ID: <20110711.193359.1440272794251078589.davem@davemloft.net>
References: <1310421182.2860.22.camel@edumazet-laptop>
	<CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab1GLCeC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 22:34:02 -0400
In-Reply-To: <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 11 Jul 2011 16:51:23 -0700

> On Mon, Jul 11, 2011 at 14:53, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>> Note : This patch is untested, I dont have the hardware
>>
>> Thanks
>>
>> [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at init =
time
>>
>> In process and sleep allowed context, favor GFP_KERNEL allocations o=
ver
>> GFP_ATOMIC ones.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Ben Greear <greearb@candelatech.com>
>> CC: Bruce Allan <bruce.w.allan@intel.com>
>> ---
>> =A0drivers/net/e1000e/e1000.h =A0| =A0 =A02 +-
>> =A0drivers/net/e1000e/netdev.c | =A0 33 +++++++++++++++++-----------=
-----
>> =A02 files changed, 18 insertions(+), 17 deletions(-)
>>
>=20
> Thanks Eric!  I have added the patch to my queue.

You can't until I put patch #1 into my tree, which adds the
new interfaces used by this patch.

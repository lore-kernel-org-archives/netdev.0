From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Mon, 11 Jul 2011 16:51:23 -0700
Message-ID: <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
References: <1310421182.2860.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:64875 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab1GKXvZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 19:51:25 -0400
Received: by fxd18 with SMTP id 18so4422761fxd.11
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 16:51:24 -0700 (PDT)
In-Reply-To: <1310421182.2860.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 14:53, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Note : This patch is untested, I dont have the hardware
>
> Thanks
>
> [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at init t=
ime
>
> In process and sleep allowed context, favor GFP_KERNEL allocations ov=
er
> GFP_ATOMIC ones.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ben Greear <greearb@candelatech.com>
> CC: Bruce Allan <bruce.w.allan@intel.com>
> ---
> =C2=A0drivers/net/e1000e/e1000.h =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 33 +++++++++++++++++------=
----------
> =C2=A02 files changed, 18 insertions(+), 17 deletions(-)
>

Thanks Eric!  I have added the patch to my queue.

--=20
Cheers,
Jeff

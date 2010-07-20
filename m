From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix ethtool stats
Date: Tue, 20 Jul 2010 15:06:40 -0700
Message-ID: <AANLkTik7JrI3HrtvQRTgrRU30fFb2lrgGxUJsWXedBL0@mail.gmail.com>
References: <1279646906.2498.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49561 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761475Ab0GTWGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 18:06:41 -0400
Received: by gwj18 with SMTP id 18so3060128gwj.19
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 15:06:40 -0700 (PDT)
In-Reply-To: <1279646906.2498.103.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 10:28, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Note : I am currently unable to test following patch, could you pleas=
e
> Intel guys test it and Ack (or Nack) it ?
>
> Thanks !
>
> [PATCH net-next-2.6] ixgbe: fix ethtool stats
>
> In latest changes about 64bit stats on 32bit arches,
> [commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit arches)=
],
> I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
> definition.
>
> IXGBE_NETDEV_STAT() must now assume offsets relative to
> rtnl_link_stats64, not relative do dev->stats.
>
> As a bonus, we also get 64bit stats on ethtool -S
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 42 ++++++++++++++---=
-----------
> =C2=A01 file changed, 21 insertions(+), 21 deletions(-)
>

Thanks Eric, I have added it to my queue.

--=20
Cheers,
Jeff

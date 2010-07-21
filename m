From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix ethtool stats
Date: Wed, 21 Jul 2010 13:17:13 -0700
Message-ID: <AANLkTinqcK+xO1GH9fA2Wc=2_5W_RBcfS8NyHdxvbwbm@mail.gmail.com>
References: <1279646906.2498.103.camel@edumazet-laptop>
	<AANLkTik7JrI3HrtvQRTgrRU30fFb2lrgGxUJsWXedBL0@mail.gmail.com>
	<1279679904.2492.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45533 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab0GUURR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:17:17 -0400
Received: by yxg6 with SMTP id 6so10971yxg.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:17:16 -0700 (PDT)
In-Reply-To: <1279679904.2492.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 19:38, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Le mardi 20 juillet 2010 =C3=A0 15:06 -0700, Jeff Kirsher a =C3=A9cri=
t :
>> On Tue, Jul 20, 2010 at 10:28, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> > Note : I am currently unable to test following patch, could you pl=
ease
>> > Intel guys test it and Ack (or Nack) it ?
>> >
>> > Thanks !
>> >
>> > [PATCH net-next-2.6] ixgbe: fix ethtool stats
>> >
>> > In latest changes about 64bit stats on 32bit arches,
>> > [commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit arch=
es)],
>> > I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
>> > definition.
>> >
>> > IXGBE_NETDEV_STAT() must now assume offsets relative to
>> > rtnl_link_stats64, not relative do dev->stats.
>> >
>> > As a bonus, we also get 64bit stats on ethtool -S
>> >
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > ---
>> > =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 42 ++++++++++++++=
--------------
>> > =C2=A01 file changed, 21 insertions(+), 21 deletions(-)
>> >
>>
>> Thanks Eric, I have added it to my queue.
>>
>
> Thanks !
>
> By the way, my ixgbe conf doesnt like net-next-2.6 at all.
> (No link is established in my fiber loop configuration)
>
> current linux-2.6 git runs correctly, link at 10Gb, so there is a
> regression somewhere.
>
> As this machine is quite slow (I dont have anymore my Nehalem dev
> machine, had to use an old setup), a bisection would take one month..=
=2E
>
>

Eric - can you send your setup and .config so that we can take a look
at why your not getting a link?

--=20
Cheers,
Jeff

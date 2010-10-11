From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] NET: pch, fix use after free
Date: Mon, 11 Oct 2010 11:13:23 -0700 (PDT)
Message-ID: <20101011.111323.115931626.davem@davemloft.net>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
	<1286789918.2737.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	masa-korg@dsn.okisemi.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756053Ab0JKSNB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 14:13:01 -0400
In-Reply-To: <1286789918.2737.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 11:38:38 +0200

> Le lundi 11 octobre 2010 =E0 11:26 +0200, Jiri Slaby a =E9crit :
>> Stanse found that pch_gbe_xmit_frame uses skb after it is freed. Fix
>> that.
>>=20
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
>> ---
>>  drivers/net/pch_gbe/pch_gbe_main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> Applicable to net-next-2.6 only, this driver is not yet in Linus tree
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this to net-next-2.6, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: check for refcount if pop a stacked dst_entry
Date: Fri, 04 Jun 2010 15:58:23 -0700 (PDT)
Message-ID: <20100604.155823.28795662.davem@davemloft.net>
References: <1275648679.2482.43.camel@edumazet-laptop>
	<20100604115737.GA5570@secunet.com>
	<1275653207.2482.120.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48373
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757289Ab0FDW6N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 18:58:13 -0400
In-Reply-To: <1275653207.2482.120.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Jun 2010 14:06:47 +0200

> Le vendredi 04 juin 2010 =E0 13:57 +0200, Steffen Klassert a =E9crit =
:
>> xfrm triggers a warning if dst_pop() drops a refcount
>> on a noref dst. This patch changes dst_pop() to
>> skb_dst_pop(). skb_dst_pop() drops the refcnt only
>> on a refcounted dst. Also we don't clone the child
>> dst_entry, so it is not refcounted and we can use
>> skb_dst_set_noref() in xfrm_output_one().
>>=20
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> ---
>=20
> Thanks a lot Steffen !
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks guys!

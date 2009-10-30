From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 23:43:12 -0700 (PDT)
Message-ID: <20091029.234312.06466996.davem@davemloft.net>
References: <4AE9AA01.3020805@gmail.com>
	<4AE9D000.90603@trash.net>
	<4AEA8813.9090505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46666
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756075AbZJ3Gms convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 02:42:48 -0400
In-Reply-To: <4AEA8813.9090505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Oct 2009 07:30:43 +0100

> Patrick McHardy a =E9crit :
>> Eric Dumazet wrote:
>>> Patrick McHardy a =E9crit :
>>>
>>>> Indeed, but unregister_vlan_dev() destroys the group once the
>>>> count has reached zero, so we must not access it after that.
>>> Well, I hoped call_rcu() callback doesnt fire and kfree(grp) until =
we exited
>>> from unregister_vlan_dev_alls(), with RTNL locked...
>>=20
>> The RTNL is a mutex, so it shouldn't prevent call_rcu from firing.
>=20
> Oops this is totally right of course, so your patch is actually a bug=
 fix :)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I've applied Patrick's patch, thanks everyone.

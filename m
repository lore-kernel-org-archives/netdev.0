From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix an RCU warning in dev_pick_tx()
Date: Wed, 21 Apr 2010 01:10:57 -0700 (PDT)
Message-ID: <20100421.011057.226808869.davem@davemloft.net>
References: <20100420102558.31923.91.stgit@warthog.procyon.org.uk>
	<1271779414.7895.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886Ab0DUILN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 04:11:13 -0400
In-Reply-To: <1271779414.7895.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 18:03:34 +0200

> Le mardi 20 avril 2010 =E0 11:25 +0100, David Howells a =E9crit :
>> Fix the following RCU warning in dev_pick_tx():
 ...
> Absolutely right, thanks David
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, thanks everyone.

> This might conflict with following commit in net-next-2.6, where I ch=
ose
> the rcu_dereference_check() alternative

Yead I'll be mindful of this when I do a merge right after
this, thanks for the heads up.

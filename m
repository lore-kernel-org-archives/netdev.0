From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Refcount destination entry on xfrm_lookup
Date: Wed, 16 Mar 2011 12:56:00 -0700 (PDT)
Message-ID: <20110316.125600.232748117.davem@davemloft.net>
References: <20110316071249.GS31402@secunet.com>
	<4D806ECB.4000205@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753528Ab1CPTzW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 15:55:22 -0400
In-Reply-To: <4D806ECB.4000205@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 16 Mar 2011 10:03:23 +0200

> On 03/16/2011 09:12 AM, Steffen Klassert wrote:
>> We return a destination entry without refcount if a socket
>> policy is found in xfrm_lookup. This triggers a warning on
>> a negative refcount when freeeing this dst entry. So take
>> a refcount in this case to fix it.
>>=20
>> This refcount was forgotten when xfrm changed to cache bundles
>> instead of policies for outgoing flows.
>>=20
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>=20
> Acked-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> Ok. This is one of the corner cases I did not test: having socket pol=
icy
> something else than no action. I just didn't have the application rea=
dy
> for it. Sorry about the bug. And good catch Steffen.

Applied and queued up for -stable, thanks!

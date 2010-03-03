From: David Miller <davem@davemloft.net>
Subject: Re: [Bridge] [PATCH] bridge: per-cpu packet statistics (v3)
Date: Wed, 03 Mar 2010 01:16:33 -0800 (PST)
Message-ID: <20100303.011633.133428196.davem@davemloft.net>
References: <1267553173.2839.9.camel@edumazet-laptop>
	<20100302153209.74742a96@nehalam>
	<1267596544.2839.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754850Ab0CCJQO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 04:16:14 -0500
In-Reply-To: <1267596544.2839.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Mar 2010 07:09:04 +0100

> Le mardi 02 mars 2010 =E0 15:32 -0800, Stephen Hemminger a =E9crit :
>> The shared packet statistics are a potential source of slow down
>> on bridged traffic. Convert to per-cpu array, but only keep those
>> statistics which change per-packet.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>=20
> Thanks Stephen !
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This is fine but needs to go into the next merge window, not
this one.

Bug fixes only now.

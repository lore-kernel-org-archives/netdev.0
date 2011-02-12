From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] network: Allow af_packet to transmit +4 bytes
 for VLAN packets.
Date: Fri, 11 Feb 2011 21:26:49 -0800 (PST)
Message-ID: <20110211.212649.35034901.davem@davemloft.net>
References: <1297452918-16993-1-git-send-email-greearb@candelatech.com>
	<1297462718.2510.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41516
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129Ab1BLF0N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Feb 2011 00:26:13 -0500
In-Reply-To: <1297462718.2510.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 11 Feb 2011 23:18:38 +0100

> Le vendredi 11 f=E9vrier 2011 =E0 11:35 -0800, greearb@candelatech.co=
m a
> =E9crit :
>> From: Ben Greear <greearb@candelatech.com>
>>=20
>> This allows user-space to send a '1500' MTU VLAN packet on a
>> 1500 MTU ethernet frame.  The extra 4 bytes of a VLAN header is
>> not usually charged against the MTU when other parts of the
>> network stack is transmitting vlans...
>>=20
>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>> ---
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks.

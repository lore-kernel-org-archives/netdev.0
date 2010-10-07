From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Wed, 06 Oct 2010 23:46:11 -0700 (PDT)
Message-ID: <20101006.234611.191419337.davem@davemloft.net>
References: <20101005141833.20929.10943.stgit@localhost>
	<20101006.233611.68115178.davem@davemloft.net>
	<1286433848.9417.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757882Ab0JGGpt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 02:45:49 -0400
In-Reply-To: <1286433848.9417.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 08:44:08 +0200

> Le mercredi 06 octobre 2010 =E0 23:36 -0700, David Miller a =E9crit :
>> From: Jesper Dangaard Brouer <hawk@comx.dk>
>> Date: Tue, 05 Oct 2010 16:18:33 +0200
>>=20
>> > Network driver igb: Improve the accuracy of stats in /proc/net/dev=
, by
>> > updating the adapter stats when reading /proc/net/dev.  Currently =
the
>> > stats are updated by the watchdog timer every 2 sec, or when getti=
ng
>> > stats via ethtool -S.
>> >=20
>> > A number of userspace apps read these /proc/net/dev stats every se=
cond,
>> > e.g. ifstat, which then gives a perceived very bursty traffic patt=
ern,
>> > which is actually false.
>> >=20
>> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>>=20
>> I assume that the Intel folks will take care of integrating this
>> now that the locking is fixed.
>>=20
>=20
> I integrated Jesper patch into my cumulative patch.

Ok.

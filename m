From: David Miller <davem@davemloft.net>
Subject: Re: [v2] Fix NULL dereference in x25_recvmsg
Date: Wed, 02 Nov 2011 00:50:35 -0400 (EDT)
Message-ID: <20111102.005035.352160644689659268.davem@davemloft.net>
References: <1320200165.4728.25.camel@edumazet-laptop>
	<20111102022644.GB8512@redhat.com>
	<1320201017.4728.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davej@redhat.com, netdev@vger.kernel.org, mattjd@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1KBEuj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 00:50:39 -0400
In-Reply-To: <1320201017.4728.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2011 03:30:17 +0100

> Le mardi 01 novembre 2011 =E0 22:26 -0400, Dave Jones a =E9crit :
>> commit cb101ed2 in 3.0 introduced a bug in x25_recvmsg()
>> When passed bogus junk from userspace, x25->neighbour can be NULL,
>> as shown in this oops..
>>=20
> ...
>> Signed-off-by: Dave Jones <davej@redhat.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks everyone.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Fix locking in flush_backlog
Date: Tue, 23 Mar 2010 23:17:59 -0700 (PDT)
Message-ID: <20100323.231759.94840161.davem@davemloft.net>
References: <alpine.DEB.1.00.1003231635190.360@pokey.mtv.corp.google.com>
	<1269408882.2915.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35688
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799Ab0CXGRf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 02:17:35 -0400
In-Reply-To: <1269408882.2915.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 06:34:42 +0100

> Le mardi 23 mars 2010 =E0 16:39 -0700, Tom Herbert a =E9crit :
>> Need to take spinlocks when dequeuing from input_pkt_queue in flush_=
backlog.
>> Also, flush_backlog can now be called directly from netdev_run_todo.
>>=20
>> Signed-off-by: Tom Herbert <therbert@google.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

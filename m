From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 10:25:40 +0200
Message-ID: <18685.37380.34636.316536@robur.slu.se>
References: <20081020190922.7dd6510a@extreme>
	<48FD6E8A.6060304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:32868 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYJUIf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 04:35:56 -0400
In-Reply-To: <48FD6E8A.6060304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:
 > Stephen Hemminger a =E9crit :
 > > Add support for recycling tx buffers into receive buffers.
 > > This is experimental at this point.
 > >=20
 >=20
 > I really like this skb recycling

Hi,

Well the best and cleanest thing would be if the "global" recycler slab=
/slub=20
was fast enough. Historically it seems like every time the link speed i=
ncreases=20
(now to 10g) alloc/kfree pops up on the profiles but that challenge has=
 sofar
been handled by slab/slub folks. Maybe we should consult them first...

Also there was some discussions to have packet objects in slab.
=20
Cheers.
					--ro

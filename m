From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 13:17:57 +0200
Message-ID: <20110711111757.GC7532@rere.qmqm.pl>
References: <20110711091649.GA6380@rere.qmqm.pl>
 <20110711.022403.532062888492669176.davem@davemloft.net>
 <20110711094723.GC6380@rere.qmqm.pl>
 <20110711.031128.635136897396133223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46111 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754788Ab1GKLR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 07:17:58 -0400
Content-Disposition: inline
In-Reply-To: <20110711.031128.635136897396133223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 03:11:28AM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 11 Jul 2011 11:47:23 +0200
>=20
> > Catch 22: The chips are not tested because they have always free bu=
ffers,
> > they are provided with endless rx buffers because they are not bein=
g
> > tested. I'd rather test them well rather than workaround a phantom =
issue.
> > Tripping on empty free rx buffer ring is still possible even with s=
cheme
> > #1 (eg. with lots of NICs receiving heavy traffic) --- just harder =
to
> > recognise and debug (if it breaks at all) when it happens.
> I do not support taking this risk.

The problem will be waiting, just pushed into dark corner. ;)
The card+driver need to survive empty rx buffer list anyway.

This issue will come back with people attacking bufferbloat issues
(they will want to reduce queue sizes and so increase the frequency
when free rx buffers run out).

> Please do not submit patches which move away from the long
> standing allocation failure handling scheme.

Sure. In this series it's patch 16 --- because it was trivial to do. Pe=
nding
patches only wrap the existing behaviour (where clearly scheme #1 or #2
is used).

Best Regards,
Micha=B3 Miros=B3aw

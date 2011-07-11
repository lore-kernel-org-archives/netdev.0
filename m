From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 03:11:28 -0700 (PDT)
Message-ID: <20110711.031128.635136897396133223.davem@davemloft.net>
References: <20110711091649.GA6380@rere.qmqm.pl>
	<20110711.022403.532062888492669176.davem@davemloft.net>
	<20110711094723.GC6380@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab1GKKMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 06:12:44 -0400
In-Reply-To: <20110711094723.GC6380@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 11 Jul 2011 11:47:23 +0200

> Catch 22: The chips are not tested because they have always free buff=
ers,
> they are provided with endless rx buffers because they are not being
> tested. I'd rather test them well rather than workaround a phantom is=
sue.
> Tripping on empty free rx buffer ring is still possible even with sch=
eme
> #1 (eg. with lots of NICs receiving heavy traffic) --- just harder to
> recognise and debug (if it breaks at all) when it happens.

I do not support taking this risk.

Please do not submit patches which move away from the long
standing allocation failure handling scheme.

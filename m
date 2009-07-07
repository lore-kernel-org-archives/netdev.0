From: David Miller <davem@davemloft.net>
Subject: Re: use after free bug in socket code
Date: Tue, 07 Jul 2009 08:19:30 -0700 (PDT)
Message-ID: <20090707.081930.92299470.davem@davemloft.net>
References: <19020.39270.408816.360526@ipc1.ka-ro>
	<20090706.190709.214907244.davem@davemloft.net>
	<19026.62063.501414.659047@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
To: LW@KARO-electronics.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755151AbZGGPT1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 11:19:27 -0400
In-Reply-To: <19026.62063.501414.659047@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Tue, 7 Jul 2009 08:59:59 +0200

> To me it seems much more logical to invalidate any references from
> some object 'B' (struct sock) to some object 'A' (struct socket) when
> object 'A' is being released rather than invalidating them when objec=
t
> 'B' is being released.

Because B should hold a reference to A in that situation.

If one object refers to another, it should grab and hold a reference
to that object.

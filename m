From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rfkill/rfkill.c: fix unused rfkill_led_trigger()
 warning
Date: Sun, 04 Jan 2009 17:11:33 -0800 (PST)
Message-ID: <20090104.171133.149921284.davem@davemloft.net>
References: <1230714558.24416.1.camel@odie.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: IvDoorn@gmail.com, netdev@vger.kernel.org
To: odie@cs.aau.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41316
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbZAEBL3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jan 2009 20:11:29 -0500
In-Reply-To: <1230714558.24416.1.camel@odie.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Simon Holm Th=F8gersen <odie@cs.aau.dk>
Date: Wed, 31 Dec 2008 10:09:18 +0100

> commit 4dec9b807be757780ca3611a959ac22c28d292a7 ("rfkill: strip point=
less
> notifier chain") removed the only user of rfkill_led_trigger() that w=
as not
> guarded by #ifdef CONFIG_RFKILL_LEDS. Therefore, move rfkill_led_trig=
ger()
> completely inside #ifdef CONFIG_RFKILL_LEDS and avoid the compile tim=
e
> warning:
>=20
> net/rfkill/rfkill.c:59: warning: 'rfkill_led_trigger' defined but not=
 used
>=20
> Signed-off-by: Simon Holm Th=F8gersen <odie@cs.aau.dk>

Applied, thanks Simon.

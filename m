From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 14:31:21 -0700 (PDT)
Message-ID: <20110714.143121.1603730405553208694.davem@davemloft.net>
References: <1310603009.2756.8.camel@bwh-desktop>
	<CA+mtBx9GXf_+DGB4EabS74Hf+16KKJ78Ty_zK6Y3tC+X634jtA@mail.gmail.com>
	<20110714205623.GD16759@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381Ab1GNVbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 17:31:32 -0400
In-Reply-To: <20110714205623.GD16759@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 22:56:23 +0200

> That's why its turned off by default and should be enabled only when =
user
> knows he will win some pps with it.

More people are going to lose than win by your change.

The nocopy feature helps more real situations than it hurts, the
existing default is the best.

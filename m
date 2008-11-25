From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Mon, 24 Nov 2008 21:10:39 -0800 (PST)
Message-ID: <20081124.211039.01283732.davem@davemloft.net>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40898
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYKYFKk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:10:40 -0500
In-Reply-To: <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:21:59 +0200

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I applied this with a minor modification.

tcp_skb_mark_lost_uncond_verify() can now be marked static, so I made
that change.

BTW, that would have generated a sparse warning had you sparse on
your changes :)

From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 01:44:58 -0800 (PST)
Message-ID: <20080117.014458.16733544.davem@davemloft.net>
References: <478F1DEA.5070903@iki.fi>
	<20080117.013107.241902256.davem@davemloft.net>
	<478F2205.80403@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751729AbYAQJpE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 04:45:04 -0500
In-Reply-To: <478F2205.80403@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 11:38:13 +0200

> The af_key issue is that in big dumps you get only first X
> entries. The rest of the entries are dropped because the
> socket receive buffer goes full. You get data corruption:
> missing entries.

This is an inherent aspect of AF_KEY (and what it was
derived from, BSD routing sockets).

It has to provide dumps atomically, and if there is no
space there is no way to provide those entries which
would require more rcvbuf space.

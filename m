From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [TCP]: Split SACK FRTO flag clearing (fixes FRTO
 corner case bug)
Date: Sat, 10 Nov 2007 21:24:34 -0800 (PST)
Message-ID: <20071110.212434.152764344.davem@davemloft.net>
References: <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11946921622225-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11946921624037-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751339AbXKKFYf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 00:24:35 -0500
In-Reply-To: <11946921624037-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 10 Nov 2007 12:56:02 +0200

> In case we run out of mem when fragmenting, the clearing of
> FLAG_ONLY_ORIG_SACKED might get missed which then feeds FRTO
> with false information. Move clearing outside skb processing
> loop so that it will get executed even if the skb loop
> terminates prematurely due to out-of-mem.
>=20
> Besides, now the core of the loop truly deals with a single
> skb only, which also enables creation a more self-contained
> of tcp_sacktag_one later on.
>=20
> In addition, small reorganization of if branches was made.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks!

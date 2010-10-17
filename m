From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: use correct counters in CA_CWR state too
Date: Sun, 17 Oct 2010 13:47:03 -0700 (PDT)
Message-ID: <20101017.134703.112598933.davem@davemloft.net>
References: <alpine.DEB.2.00.1010141450290.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932785Ab0JQUqk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Oct 2010 16:46:40 -0400
In-Reply-To: <alpine.DEB.2.00.1010141450290.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 14 Oct 2010 14:52:09 +0300 (EEST)

> As CWR is stronger than CA_Disorder state, we can miscount
> SACK/Reno failure into other timeouts. Not a bad problem as
> it can happen only due to ECN, FRTO detecting spurious RTO
> or xmit error which are the only callers of tcp_enter_cwr.
> And even then losses and RTO must still follow thereafter
> to actually end up into the relevant code paths.
>=20
> Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied to net-next-2.6, thanks.

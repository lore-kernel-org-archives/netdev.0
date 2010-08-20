From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Fri, 20 Aug 2010 01:43:21 -0700 (PDT)
Message-ID: <20100820.014321.45884355.davem@davemloft.net>
References: <20100818231035.GD24125@n7mm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: baronchon@n7mm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557Ab0HTInF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 04:43:05 -0400
In-Reply-To: <20100818231035.GD24125@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gr=E9goire Baron <baronchon@n7mm.org>
Date: Thu, 19 Aug 2010 01:10:35 +0200

> net/sched: add ACT_CSUM action to update packets checksums
>=20
> ACT_CSUM can be called just after ACT_PEDIT in order to re-compute so=
me
> altered checksums in IPv4 and IPv6 packets. The following checksums a=
re
> supported by this patch:
>  - IPv4: IPv4 header, ICMP, IGMP, TCP, UDP & UDPLite
>  - IPv6: ICMPv6, TCP, UDP & UDPLite
> It's possible to request in the same action to update different kind =
of
> checksums, if the packets flow mix TCP, UDP and UDPLite, ...
>=20
> An example of usage is done in the associated iproute2 patch.
>=20
> Version 3 changes:
>  - remove useless goto instructions
>  - improve IPv6 hop options decoding
>=20
> Version 2 changes:
>  - coding style correction
>  - remove useless arguments of some functions
>  - use stack in tcf_csum_dump()
>  - add tcf_csum_skb_nextlayer() to factor code
>=20
> Acked-by: jamal <hadi@cyberus.ca>
> Signed-off-by: Gregoire Baron <baronchon@n7mm.org>

Applied, thanks.

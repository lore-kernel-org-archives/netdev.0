From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: NETIF_F_TSO vs NETIF_F_TSO{6,_ECN}
Date: Tue, 5 Apr 2011 20:03:37 +0200
Message-ID: <20110405180337.GA16977@rere.qmqm.pl>
References: <1302018602.2932.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50784 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736Ab1DESDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 14:03:38 -0400
Content-Disposition: inline
In-Reply-To: <1302018602.2932.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 04:50:02PM +0100, Ben Hutchings wrote:
> According to the commit that introduced NETIF_F_TSO6
> (f83ef8c0b58dac17211a4c0b6df0e2b1bd6637b1):
>    =20
>         This patch will introduce a new flag NETIF_F_TSO6 which will =
be used
>         to check whether device supports TSO over IPv6. If device sup=
port TSO
>         over IPv6 then we don't clear of NETIF_F_TSO and which will m=
ake the
>         TCP layer to create TSO packets. Any device supporting TSO ov=
er IPv6
>         will set NETIF_F_TSO6 flag in "dev->features" along with NETI=
=46_F_TSO.
>    =20
>         In case when user disables TSO using ethtool, NETIF_F_TSO wil=
l get
>         cleared from "dev->features". So even if we have NETIF_F_TSO6=
 we don't
>         get TSO packets created by TCP layer.
>=20
> So I think we need to either:
> 1. Disallow toggling NETIF_F_TSO6 (following the previous rule)
> 2. Disable NETIF_F_TSO6 when NETIF_F_TSO is disabled
>=20
> The same presumably applies to NETIF_F_TSO_ECN.

There seems to be no such dependency in the networking code. I.e. TSO6
should just work with TSO4 disabled.

Best Regards,
Micha=B3 Miros=B3aw

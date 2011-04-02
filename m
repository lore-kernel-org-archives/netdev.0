From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert SMSC USB net drivers to hw_features
Date: Fri, 01 Apr 2011 20:54:47 -0700 (PDT)
Message-ID: <20110401.205447.245401122.davem@davemloft.net>
References: <20110331110135.E66E413A6B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752339Ab1DBDzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:55:25 -0400
In-Reply-To: <20110331110135.E66E413A6B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)

> There's a race (not fixed here) in smsc75xx in setting RFE_CTL that's=
 not
> properly handled via rfe_ctl_lock. Spinlock is not a good tool here, =
as
> this has to wait for URB completion (or maybe just submission) after =
issuing
> register write request. Otherwise, the rfe_ctl might be changed just =
after
> spin_unlock() and device left programmed with other value.
>=20
> smsc95xx has increased hard_header_len for the case of TX checksummin=
g.
>=20
> smsc75xx is fixed to advertise IP+IPV6_CSUM instead of HW_CSUM as it =
does
> not use csum_start/csum_offset.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.

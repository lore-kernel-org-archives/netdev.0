From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 15:02:18 +0100
Message-ID: <1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
	 <1324465434.7877.11.camel@zakaz.uk.xensource.com>
	 <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324466290.7877.22.camel@zakaz.uk.xensource.com>
	 <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324475280.7877.33.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44933 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab1LUOCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:02:22 -0500
Received: by vbbfc26 with SMTP id fc26so5801855vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 06:02:21 -0800 (PST)
In-Reply-To: <1324475280.7877.33.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 13:48 +0000, Ian Campbell a =C3=
=A9crit :
> On Wed, 2011-12-21 at 12:30 +0000, Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:18 +0000, Ian Campbell =
a =C3=A9crit :
> >=20
> > >=20
> > > An order 1 allocation is in multiples of PAGE_SIZE, isn't it, eve=
n
> > > though they happen to be contiguous?
> >=20
> > Really an order-1 allocation allocates one page, a compound one.
>=20
> Oh, right, I see what you mean.
>=20
> You snipped the question about the + 2, I take it you have no idea wh=
at
> it is all about either?
>=20

No idea on this +2 point.

I know some hardwares have limits on a fragment length (for example IGB
uses IGB_MAX_DATA_PER_TXD limit), but I dont know why we add extra frag=
s
in generic skb.

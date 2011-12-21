From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 13:48:00 +0000
Message-ID: <1324475280.7877.33.camel@zakaz.uk.xensource.com>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
	 <1324465434.7877.11.camel@zakaz.uk.xensource.com>
	 <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324466290.7877.22.camel@zakaz.uk.xensource.com>
	 <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:44183 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab1LUNsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:48:03 -0500
In-Reply-To: <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 12:30 +0000, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:18 +0000, Ian Campbell a =
=C3=A9crit :
>=20
> >=20
> > An order 1 allocation is in multiples of PAGE_SIZE, isn't it, even
> > though they happen to be contiguous?
>=20
> Really an order-1 allocation allocates one page, a compound one.

Oh, right, I see what you mean.

You snipped the question about the + 2, I take it you have no idea what
it is all about either?

Ian.

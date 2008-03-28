From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to
 facilitate percpu inuse accounting (v2).
Date: Fri, 28 Mar 2008 16:40:18 -0700 (PDT)
Message-ID: <20080328.164018.126797569.davem@davemloft.net>
References: <47ECE4B7.40806@openvz.org>
	<47ED27C7.5000202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754399AbYC1XkY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:40:24 -0400
In-Reply-To: <47ED27C7.5000202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 18:15:51 +0100

> Pavel Emelyanov a =E9crit :
> > The inuse counters are going to become a per-cpu array.
> > Introduce an index for this array on the struct proto.
> >
> > To handle the case of proto register-unregister-register
> > loop the bitmap is used. All its bits manipulations are
> > protected with proto_list_lock and a sanity check for the
> > bitmap being exhausted is also added.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >
> >  =20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.


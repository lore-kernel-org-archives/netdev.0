From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Mon, 24 Nov 2008 20:07:10 +0100
Message-ID: <20081124190710.GA6703@one.firstfloor.org>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi> <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi> <87skphqdx7.fsf@basil.nowhere.org> <Pine.LNX.4.64.0811241844490.30728@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60652 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbYKXS4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 13:56:55 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811241844490.30728@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 06:58:25PM +0200, Ilpo J=E4rvinen wrote:
> On Mon, 24 Nov 2008, Andi Kleen wrote:
>=20
> > "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> writes:
> >=20
> > tcp: move tcp_simple_retransmit to tcp_input
> >=20
> > Why? It seems like a clear output function.
>=20
> What makes you think so? It's as much output as e.g., tcp_enter_loss

the path mtu code calls it to output a packet.

> (or in fact less than that since enter_loss is triggered mainly by rt=
o)?

enter_loss doesn't send a packet.

-Andi

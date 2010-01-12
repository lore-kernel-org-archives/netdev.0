From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 17:35:49 +0100
Message-ID: <4B4CA4E5.7030800@gmail.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Kosin <JKosin@intcomgrp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41245 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab0ALQgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 11:36:11 -0500
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC to netdev

Le 12/01/2010 16:39, James Kosin a =E9crit :
> Everyone,
>=20
> Since, a AT91_EMAC_TUND only happens when the transmitter is unable t=
o
> transfer the frame in time for a frame to be sent.  It makes sense to
> RETRY the packet in this condition in the ISR.
> Or would this overcomplicate a simple task?
>                 ... see below ...
>=20
=2E..

>=20
> ...
> I do know there needs to be a bit more code then to handle the
> successful case below this; but, this is enough to understand what I =
am
> talking about.  The UNDERRUN error should happen infrequently and in
> ideal circumstances not happen at all.
> =20


If this happens once in a while, why do you want driver to retry the tr=
ansmit ?

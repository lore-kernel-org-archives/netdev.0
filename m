From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atm: Cleanup redundant tests on unsigned
Date: Fri, 23 Oct 2009 18:08:30 +0200
Message-ID: <4AE1D4FE.5090902@gmail.com>
References: <4AE1D553.8010406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54709 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbZJWQLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:11:52 -0400
In-Reply-To: <4AE1D553.8010406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin a =E9crit :
> The variables are unsigned so the `< 0' test always fails, the
> other part of the test catches wrapped values.
>=20
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---

I believe such patches were posted in the past.

General consensus is that compiler is able to do this optimization for =
us,
and reader doesnt have to ask to himself : "Is the test safe enough ?"


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bpf_jit: fix an off-one bug in x86_64 cond jump
 target
Date: Mon, 19 Dec 2011 15:48:58 -0500 (EST)
Message-ID: <20111219.154858.115846786393903637.davem@davemloft.net>
References: <1324157948.3323.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nepenthesdev@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1LSUtC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:49:02 -0500
In-Reply-To: <1324157948.3323.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Dec 2011 22:39:08 +0100

> From: Markus K=F6tter <nepenthesdev@gmail.com>
>=20
> x86 jump instruction size is 2 or 5 bytes (near/long jump), not 2 or =
6
> bytes.
>=20
> In case a conditional jump is followed by a long jump, conditional ju=
mp
> target is one byte past the start of target instruction.
>=20
> Signed-off-by: Markus K=F6tter <nepenthesdev@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] af-packet: fix oops when socket is not present
Date: Wed, 07 Nov 2012 15:42:48 -0500 (EST)
Message-ID: <20121107.154248.205807168678683505.davem@davemloft.net>
References: <1352201642.3140.880.camel@edumazet-glaptop>
	<1352203810-957-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2KGUmu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 15:42:50 -0500
In-Reply-To: <1352203810-957-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Leblond <eric@regit.org>
Date: Tue,  6 Nov 2012 13:10:10 +0100

> Due to a NULL dereference, the following patch is causing oops
> in normal trafic condition:
>=20
> commit c0de08d04215031d68fa13af36f347a6cfa252ca
> Author: Eric Leblond <eric@regit.org>
> Date:=A0=A0 Thu Aug 16 22:02:58 2012 +0000
>=20
> =A0=A0=A0 af_packet: don't emit packet on orig fanout group
>=20
> This buggy patch was a feature fix and has reached most stable
> branches.
>=20
> When skb->sk is NULL and when packet fanout is used, there is a
> crash in match_fanout_group where skb->sk is accessed.
> This patch fixes the issue by returning false as soon as the
> socket is NULL: this correspond to the wanted behavior because
> the kernel as to resend the skb to all the listening socket in
> this case.
>=20
> Signed-off-by: Eric Leblond <eric@regit.org>

Applied and queued up for -stable, thanks.

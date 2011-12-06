From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 3/4] caif-shm: Bugfixes for caif_shmcore.c
Date: Tue, 06 Dec 2011 17:22:25 -0500 (EST)
Message-ID: <20111206.172225.927201711190103679.davem@davemloft.net>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323209744-9718-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1LFWWb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:22:31 -0500
In-Reply-To: <1323209744-9718-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue,  6 Dec 2011 23:15:43 +0100

> Various bugfixes for caif_shmcore.c:
> - fix deadlocks due to improper usage of spin-lock
> - add missing spin-lock init
> - don't call dev_kfree_skb() with irqs disabled,
>   use dev_kfree_skb_irq() instead.
> - fix potential skb null pointer de-reference.
>=20
> Squashed original patches from:
> Rabin Vincent <rabin.vincent@stericsson.com>
> Durga Prasada Rao BATHINA <durgaprasadarao.b@stericcson.com>
> Arun Murthy <arun.murthy@stericsson.com>
> Bibek Basu <bibek.basu@stericsson.com>
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> ---
> Change since v1:=20
> - s/dev_kfree_skb_any/dev_kfree_skb_irq/
> - fixed two pointer cast warnings

Applied.

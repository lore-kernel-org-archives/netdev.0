From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Mon, 23 Jul 2012 18:27:16 -0700 (PDT)
Message-ID: <20120723.182716.197605063109505523.davem@davemloft.net>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	a_villacis@palosanto.com, jwboyer@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab2GXB1R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 21:27:17 -0400
In-Reply-To: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 23 Jul 2012 22:55:55 +0200

> This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
>=20
> First it appears in bisection, then reverting it solves the usual
> netdev watchdog problem for different people. I don't have a proper
> fix yet so get rid of it.
>=20
> Bisected-and-reported-by: Alex Villac=EDs Lasso <a_villacis@palosanto=
=2Ecom>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Josh Boyer <jwboyer@redhat.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---
>=20
>  The original 036da... commit has been modified due to the newly intr=
oduced
>  skb_tx_timestamp in rtl8169_start_xmit. The herein included patch qu=
alifies
>  for 3.4-stable as well.

Applied to net-next and queued up for -stable, thanks.

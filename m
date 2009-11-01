From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 01 Nov 2009 09:02:11 +0100
Message-ID: <4AED4083.8040500@gmail.com>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58556 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbZKAICL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 03:02:11 -0500
In-Reply-To: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rasesh Mody a =E9crit :
> From: Rasesh Mody <rmody@brocade.com>
>=20
> This is patch 1/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Re-based source against net-next-2.6 and re-submitting the
> patch with few fixes.
>=20
> We wish this patch to be considered for inclusion in net-next-2.6

bnad->netdev->last_rx =3D jiffies

and

netdev->trans_start =3D jiffies;

are not necessary, core network handles last_rx/trans_start itself=20
and more efficently nowadays.

void bnad_reset_stats(struct net_device *netdev) seems defined but not =
used.



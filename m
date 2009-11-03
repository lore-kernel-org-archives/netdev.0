From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 2 Nov 2009 23:54:40 -0800
Message-ID: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD2835E9860@HQ-EXCH-7.corp.brocade.com>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
 <4AED4083.8040500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:50840 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbZKCHyh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 02:54:37 -0500
In-Reply-To: <4AED4083.8040500@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,=20

Thanks for your feedback. We are working on addressing these issues.

--Debashis

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Sunday, November 01, 2009 1:02 AM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Adapter Linux Open SRC Team
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device dri=
ver

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



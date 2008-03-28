From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Thu, 27 Mar 2008 17:51:40 -0700 (PDT)
Message-ID: <20080327.175140.93155828.davem@davemloft.net>
References: <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbYC1Avk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:51:40 -0400
In-Reply-To: <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:02 +0200

> Allyesconfig (v2.6.24-mm1):
>=20
> -23668  392 funcs, 104 +, 23772 -, diff: -23668 --- dev_alloc_skb
>=20
> Without many debug CONFIGs (v2.6.25-rc2-mm1):
>=20
> -12178  382 funcs, 157 +, 12335 -, diff: -12178 --- dev_alloc_skb
> dev_alloc_skb                 |  +37
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

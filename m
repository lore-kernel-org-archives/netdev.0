From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 17:43:48 -0700 (PDT)
Message-ID: <20080327.174348.05360095.davem@davemloft.net>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752183AbYC1Ant convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:43:49 -0400
In-Reply-To: <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:00 +0200

> Allyesconfig (v2.6.24-mm1):
>=20
> ~500 files changed
> ...
>  869 funcs, 198 +, 111003 -, diff: -110805 --- skb_put
>   skb_put                       | +104
>=20
> Without number of debug related CONFIGs (v2.6.25-rc2-mm1):
>=20
> -60744  855 funcs, 861 +, 61605 -, diff: -60744 --- skb_put
>   skb_put                       |  +57
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

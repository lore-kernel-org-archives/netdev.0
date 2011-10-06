From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 06 Oct 2011 17:15:19 -0400 (EDT)
Message-ID: <20111006.171519.797156146863050743.davem@davemloft.net>
References: <1317884756.24742.13.camel@dagon.hellion.org.uk>
	<1317916822.21903.252.camel@zakaz.uk.xensource.com>
	<CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org, jdmason@kudzu.us
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174Ab1JFVP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:15:27 -0400
In-Reply-To: <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Thu, 6 Oct 2011 22:45:57 +0200

> There's a catch there, though:
 ..
> dma_mapping_error() takes struct device *, so those changes should be=
:
>=20
> dma_mapping_error(&tp->pdev->dev, mapping)
>=20
> (Like skb_frag_dma_map()'s first argument).

Why don't you take a look at what I committed and pushed out
(hint: I fixed it up when I saw the build warnings)?

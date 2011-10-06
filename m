From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 22:19:35 +0100
Message-ID: <1317935975.24742.20.camel@dagon.hellion.org.uk>
References: <1317884756.24742.13.camel@dagon.hellion.org.uk>
	 <1317916822.21903.252.camel@zakaz.uk.xensource.com>
	 <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
	 <20111006.171519.797156146863050743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "mirqus@gmail.com" <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jdmason@kudzu.us" <jdmason@kudzu.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:25110 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab1JFVTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:19:37 -0400
In-Reply-To: <20111006.171519.797156146863050743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 22:15 +0100, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
> Date: Thu, 6 Oct 2011 22:45:57 +0200
>=20
> > There's a catch there, though:
>  ..
> > dma_mapping_error() takes struct device *, so those changes should =
be:
> >=20
> > dma_mapping_error(&tp->pdev->dev, mapping)
> >=20
> > (Like skb_frag_dma_map()'s first argument).
>=20
> Why don't you take a look at what I committed and pushed out
> (hint: I fixed it up when I saw the build warnings)?

I pulled your tree and it wasn't there yet and it still isn't, I guess
it's delayed in mirroring?

Ian.

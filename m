From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 22:25:02 +0100
Message-ID: <1317936302.24742.23.camel@dagon.hellion.org.uk>
References: <1317916822.21903.252.camel@zakaz.uk.xensource.com>
	 <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
	 <1317935310.24742.18.camel@dagon.hellion.org.uk>
	 <20111006.171645.1154998655978830692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "mirqus@gmail.com" <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jdmason@kudzu.us" <jdmason@kudzu.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:15896 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965315Ab1JFVZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:25:04 -0400
In-Reply-To: <20111006.171645.1154998655978830692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 22:16 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Thu, 6 Oct 2011 22:08:30 +0100
> 
> > You are absolutely right, I've no idea how I missed the very obvious
> > warning this produces. Incremental patch is below, sorry about this!
> 
> Would really love to know what your patch is against, since I
> fixed this problem when I commited your original patch.

It was against e878d78b9a74 + the original bad patch, i.e.:

$ git log --pretty=oneline net-next/master^..HEAD
80f4b53b3d2c009689178d12de0bc108ddd580cd net: fix argument to dma_mapping_error after conversion to skb_frag_dma_map
669b1ce22eedd0f7bac048299feb06c67804ed83 net: use DMA_x_DEVICE and dma_mapping_error with skb_frag_dma_map
e878d78b9a7403fabc89ecc93c56928b74d14f01 virtio-net: Verify page list size before fitting into skb

AFAICT e878d78b9a7403fabc89ecc93c56928b74d14f01 is still the head of the
public git://github.com/davem330/net-next master.

Ian.

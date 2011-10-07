From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Fri, 7 Oct 2011 06:29:17 +0100
Message-ID: <1317965357.24742.24.camel@dagon.hellion.org.uk>
References: <1317935310.24742.18.camel@dagon.hellion.org.uk>
	 <20111006.171645.1154998655978830692.davem@davemloft.net>
	 <1317936302.24742.23.camel@dagon.hellion.org.uk>
	 <20111006.175632.863279389111584127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "mirqus@gmail.com" <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jdmason@kudzu.us" <jdmason@kudzu.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:35932 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab1JGF3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 01:29:23 -0400
In-Reply-To: <20111006.175632.863279389111584127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 22:56 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Thu, 6 Oct 2011 22:25:02 +0100
> 
> > On Thu, 2011-10-06 at 22:16 +0100, David Miller wrote:
> >> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> >> Date: Thu, 6 Oct 2011 22:08:30 +0100
> >> 
> >> > You are absolutely right, I've no idea how I missed the very obvious
> >> > warning this produces. Incremental patch is below, sorry about this!
> >> 
> >> Would really love to know what your patch is against, since I
> >> fixed this problem when I commited your original patch.
> > 
> > It was against e878d78b9a74 + the original bad patch, i.e.:
> > 
> > $ git log --pretty=oneline net-next/master^..HEAD
> > 80f4b53b3d2c009689178d12de0bc108ddd580cd net: fix argument to dma_mapping_error after conversion to skb_frag_dma_map
> > 669b1ce22eedd0f7bac048299feb06c67804ed83 net: use DMA_x_DEVICE and dma_mapping_error with skb_frag_dma_map
> > e878d78b9a7403fabc89ecc93c56928b74d14f01 virtio-net: Verify page list size before fitting into skb
> > 
> > AFAICT e878d78b9a7403fabc89ecc93c56928b74d14f01 is still the head of the
> > public git://github.com/davem330/net-next master.
> 
> I'm and idiot, I didn't push it out when I left the office :-/
> 
> Sorry.

No problem.

> But when your commit appears it will have the dma_mapping_error() stuff
> fixed up, so don't worry about it. :-)

Thanks!

Ian.

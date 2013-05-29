From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 7/7] net,ipv4,ipv6: Correct assignment of
 skb->network_header to skb->tail
Date: Wed, 29 May 2013 15:01:46 +0900
Message-ID: <20130529060143.GA20197@verge.net.au>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
 <1369805268-6291-8-git-send-email-horms@verge.net.au>
 <1369805751.5109.1.camel@edumazet-glaptop>
 <20130528.224433.533003178906165918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52506 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab3E2GBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:01:05 -0400
Content-Disposition: inline
In-Reply-To: <20130528.224433.533003178906165918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 10:44:33PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 28 May 2013 22:35:51 -0700
> 
> > Are you sure __u64 is needed on 32bit arches ?
> 
> It should be "unsigned long" or similar.

Thanks, I will fix that and re-post.

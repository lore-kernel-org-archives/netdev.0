From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: don't set NETIF_F_FRAGLIST
Date: Thu, 06 Nov 2008 10:10:29 +0000
Message-ID: <1225966229.7284.2.camel@blaa>
References: <> <1225888486-977-1-git-send-email-markmc@redhat.com>
	 <200811060853.11566.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38892 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbYKFKLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 05:11:35 -0500
In-Reply-To: <200811060853.11566.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-06 at 08:53 +1100, Rusty Russell wrote:
> On Wednesday 05 November 2008 23:34:46 Mark McLoughlin wrote:
> > We don't handle skb_shared_info->frag_list, so we shouldn't
> > be setting the NETIF_F_FRAGLIST flag.
> 
> We don't?
> 
> skb_to_sgvec() should handle it OK, is there some subtlety I'm missing?

Good grief ... yes, sorry.

Same is true for the tun patch, but I wonder ... could a fraglist skb
exceed 64k? i.e. we need to know the max possible size of a packet
before reading it from the tap.

Cheers,
Mark.


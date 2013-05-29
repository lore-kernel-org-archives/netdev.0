From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Wed, 29 May 2013 14:48:06 +0800
Message-ID: <1369810086.12227.18.camel@cr0>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
	 <20130528.233647.1209227470109213894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935020Ab3E2GsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 02:48:15 -0400
In-Reply-To: <20130528.233647.1209227470109213894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 29 May 2013 14:09:00 +0800
> 
> > commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> > fields of struct skbuff) converts skb->*_header to u16,
> > therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> > 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> > 
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Simon Horman <horms@verge.net.au>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> I want to use something that will either break the build or
> automatically work if the type changes again.
> 
> So something like "X = (typeof(X)) ~0U;".

Yeah, this is even better. I will update this patch.

Thanks.

From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Mon, 25 Jul 2011 13:53:09 +0300
Message-ID: <20110725105309.GA12439@redhat.com>
References: <20110725084057.GA30311@gondor.apana.org.au>
 <20110725094414.GA11776@redhat.com>
 <20110725095711.GA30831@gondor.apana.org.au>
 <20110725.030229.1448266647053398033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, mashirle@us.ibm.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583Ab1GYKwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2011 06:52:47 -0400
Content-Disposition: inline
In-Reply-To: <20110725.030229.1448266647053398033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 03:02:29AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.hengli.com.au>
> Date: Mon, 25 Jul 2011 17:57:11 +0800
> 
> > However, I think we should add a WARN_ON to the splice skb path
> > so that should a packet find its way through a path that we haven't
> > thought of then at least we'll know about it.
> 
> Good idea.

Another place like this is skb_split, I think.

-- 
MST

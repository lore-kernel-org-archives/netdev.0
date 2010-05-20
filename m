From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 20:05:22 -0700 (PDT)
Message-ID: <20100519.200522.140743640.davem@davemloft.net>
References: <4BF4517F.1010206@athenacr.com>
	<20100519.195533.22536631.davem@davemloft.net>
	<20100520025741.GA6129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751634Ab0ETDFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:05:14 -0400
In-Reply-To: <20100520025741.GA6129@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 May 2010 12:57:42 +1000

> On Wed, May 19, 2010 at 07:55:33PM -0700, David Miller wrote:
>> 
>> Since it seems now inevitable to me that we'll need to store the
>> 'classid' in struct sk_buff, I've prepared two patches to do that at
>> zero cost.
> 
> Actually I'm currently working on a patch to store this in struct
> sock.  The reason I prefer struct sock is because we can then
> centralise the place where we set the classid rather than having
> it spread out through every place that creates an skb.
> 
> I'll post it soon.

Ok, looking forward to it.

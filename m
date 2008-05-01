From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 12:08:48 +0100
Message-ID: <1209640128.4191.30.camel@moonstone.uk.level5networks.com>
References: <20080430214845.GC14219@solarflare.com>
	 <E1JrWFU-0001ue-00@gondolin.me.apana.org.au>
	 <20080501110225.GG14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:2691 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246AbYEALPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:15:45 -0400
In-Reply-To: <20080501110225.GG14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-01 at 12:02 +0100, Ben Hutchings wrote:
> I was going to raise the virtualisation issue because Kieran has been
> in contact with XenSource over this and they believed LRO was not a
> problem in Xen.  So long as the bridges in dom0 each connect a single
> physical interface to other domains running paravirtualised Linux, this
> is probably true. 

Yes, everything works fine in that case.  It's only when LRO packets are
forwarded to another physical interface that things go wrong.  

Kieran



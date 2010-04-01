From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Thu, 01 Apr 2010 06:53:15 -0400
Message-ID: <1270119195.26743.141.camel@bigi>
References: <20100331135505.GC14082@gondor.apana.org.au>
	 <1270044768.26743.58.camel@bigi>
	 <20100331141525.GA14331@gondor.apana.org.au>
	 <20100331.135735.00480230.davem@davemloft.net>
	 <20100401002244.GA18893@gondor.apana.org.au>
	 <1270088351.26743.121.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:33600 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab0DALBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 07:01:10 -0400
Received: by qyk4 with SMTP id 4so1208508qyk.24
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 04:01:09 -0700 (PDT)
In-Reply-To: <1270088351.26743.121.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ive tried it with net-next which is derived of 2.6.34-rc1
and it seems to work as expected
i.e. only the flush on a non-empty SAD is event-ed.
Probably older kernel you are running?

cheers,
jamal

On Wed, 2010-03-31 at 22:19 -0400, jamal wrote:
> On Thu, 2010-04-01 at 08:22 +0800, Herbert Xu wrote:
> 
> > OK, in that case please change xfrm_state_flush too.  Right now
> > it also notifies on empty.
> 
> It shouldnt. I will double check it tomorrow..
> 
> cheers,
> jamal


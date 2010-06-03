From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 03 Jun 2010 08:53:14 -0400
Message-ID: <1275569594.3445.51.camel@bigi>
References: <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
	 <1274793216.3878.947.camel@bigi>
	 <20100525231307.GA19475@gondor.apana.org.au>
	 <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi>
	 <20100603080130.GA29709@gondor.apana.org.au>
	 <1275569030.3445.49.camel@bigi>  <20100603124717.GB315@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:37851 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab0FCMxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:53:21 -0400
Received: by ywh9 with SMTP id 9so71838ywh.17
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 05:53:18 -0700 (PDT)
In-Reply-To: <20100603124717.GB315@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 22:47 +1000, Herbert Xu wrote:

> You *are* misreading what I wrote.
> 
> As I've repeatedly stated, it is guaranteed that either tcpdump
> is finished with the skb, or you will see it as cloned.

I dont see the problem of when tcpdump sees the packet first.
pedit doesnt care if it is cloned or not.
What i am worried about - and couldnt parse in your email - is:
What happens when pedit gets to it first? would skb_cloned() be true
always/guaranteed?

cheers,
jamal


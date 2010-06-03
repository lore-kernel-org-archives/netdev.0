From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 03 Jun 2010 08:58:16 -0400
Message-ID: <1275569896.3445.53.camel@bigi>
References: <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
	 <1274793216.3878.947.camel@bigi>
	 <20100525231307.GA19475@gondor.apana.org.au>
	 <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi>
	 <20100603080130.GA29709@gondor.apana.org.au>
	 <1275569030.3445.49.camel@bigi>  <20100603124717.GB315@gondor.apana.org.au>
	 <1275569594.3445.51.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51734 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130Ab0FCNFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 09:05:22 -0400
Received: by yxl31 with SMTP id 31so18089yxl.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 06:05:21 -0700 (PDT)
In-Reply-To: <1275569594.3445.51.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 08:53 -0400, jamal wrote:
> On Thu, 2010-06-03 at 22:47 +1000, Herbert Xu wrote:
> 
> > You *are* misreading what I wrote.
> > 
> > As I've repeatedly stated, it is guaranteed that either tcpdump
> > is finished with the skb, or you will see it as cloned.
> 
> I dont see the problem of when tcpdump sees the packet first.
> pedit doesnt care if it is cloned or not.
> What i am worried about - and couldnt parse in your email - is:
> What happens when pedit gets to it first? would skb_cloned() be true
> always/guaranteed?

Never mind. You did answer this question above. You are saying it is
guaranteed.
I will send patches to remove the checks in both pedit and handle_ing().
At some point i will test it....

cheers,
jamal


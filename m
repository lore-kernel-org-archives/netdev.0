From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for ip_vti.
Date: Fri, 15 Jun 2012 18:12:54 -0700 (PDT)
Message-ID: <a15f2544-29db-4fff-b9d2-9781d46019f1@tahiti.vyatta.com>
References: <20120615053707.GV27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569Ab2FPBMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 21:12:55 -0400
In-Reply-To: <20120615053707.GV27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message -----
> On Thu, Jun 14, 2012 at 07:43:59PM -0700, Saurabh Mohan wrote:
> > > +
> > > +	iph->version		= 4;
> > > +	iph->protocol		= IPPROTO_ESP;
> > 
> > Why IPPROTO_ESP? What's with the other IPsec protocols?
> > Shouldn't this be IPPROTO_IPIP?
> > 
> > @SM: VTI will work only with ESP not with AH (at least I have never
> > heard of any one using it with AH). Plus I wanted to keep this
> > module separate from IPIP (ip-in-ip tunnels).
> > 
> 
> VTI should be independent of the IPsec protocol.
> Our IPsec implementation supports AH (and IPCOMP)
> so VTI should support these protocols too.
> 
> 
That is not the intent of this feature. It is only meant to support ESP-tunnel mode. I don't know what your implementation is. 
There are many ways to skin a cat. This is just one way and that is why this feature has been implemented as a module. Thus making it optional for use.
If your objection is that I called it VTI, then I can call it "ip_esp" or something similar.

A few ppl have expressed interest in this implementation and have asked for more details and enhancements. Clearly they and our customers find it useful.
I'll resubmit with the code fixes you had mentioned.
-Saurabh

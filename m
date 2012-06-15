From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Fri, 15 Jun 2012 07:37:07 +0200
Message-ID: <20120615053707.GV27795@secunet.com>
References: <20120614091254.GT27795@secunet.com>
 <c2becb86-be73-4668-be84-82293c6c56fc@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Saurabh Mohan <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59950 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab2FOFhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 01:37:12 -0400
Content-Disposition: inline
In-Reply-To: <c2becb86-be73-4668-be84-82293c6c56fc@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 07:43:59PM -0700, Saurabh Mohan wrote:
> > +
> > +	iph->version		= 4;
> > +	iph->protocol		= IPPROTO_ESP;
> 
> Why IPPROTO_ESP? What's with the other IPsec protocols?
> Shouldn't this be IPPROTO_IPIP?
> 
> @SM: VTI will work only with ESP not with AH (at least I have never heard of any one using it with AH). Plus I wanted to keep this module separate from IPIP (ip-in-ip tunnels).
> 

VTI should be independent of the IPsec protocol.
Our IPsec implementation supports AH (and IPCOMP)
so VTI should support these protocols too.

From: Steve Chen <schen@mvista.com>
Subject: Re: [Fwd: Re: [PATCH] Multicast packet reassembly can fail]
Date: Wed, 28 Oct 2009 16:11:08 -0500
Message-ID: <1256764269.3153.494.camel@linux-1lbu>
References: <OFF3C0AE1C.0C392C88-ON8825765D.006F8D81-8825765D.006FF4C0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, mhuth@mvista.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:43049 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1754714AbZJ1VDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 17:03:20 -0400
In-Reply-To: <OFF3C0AE1C.0C392C88-ON8825765D.006F8D81-8825765D.006FF4C0@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 13:22 -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 10/28/2009 11:25:39 AM:
> 
> > I see the point you are making.  I assumed, probably incorrectly, that
> > since eth0 and eth1 have different IP address.  I would get a complete
> > series of fragments for each interface.  Perhaps, I should really be
> > looking up the stack to see why packets were dropped.  Please correct me
> > if I'm mistaken.  The normal behavior is that application should be
> > receiving either 2 (scenario 1) or 1 (scenario 2) packets.
> 
> Steve,
>         If you didn't join the group on both interfaces, you won't receive
> two copies in the first place; the unjoined NIC won't deliver anything
> up the stack that isn't in it's multicast address filter.
> 
>  +-DLS

Thanks for the inputs.  I'll revisit the issue.

Steve


From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 19:20:54 +0100
Message-ID: <1364408454.15362.1.camel@localhost>
References: <1364335457.8215.21.camel@localhost>
	 <20130327151210.GA23223@order.stressinduktion.org>
	 <1364398673.21709.4.camel@localhost>
	 <20130327181146.GB23223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:55434 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab3C0SVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:21:00 -0400
In-Reply-To: <20130327181146.GB23223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 2013-03-27 at 19:11 +0100, Hannes Frederic Sowa wrote:
> On Wed, Mar 27, 2013 at 04:37:53PM +0100, Wilco Baan Hofman wrote:
> > 
> > Weird, but sure, here goes:
> > 
> > ip tunnel add tunv6-uplink1 mode sit remote 192.168.1.1 local
> > 192.168.1.21
> > ip link set tunv6-uplink1 up mtu 1472
> 
> In my test I didn't specify the local address so addr.s6_addr32[3]
> seems to be zero.  I'll have to search the RFCs why this is the case.

See section 3.7, rfc4213:

   The interface identifier [RFC3513] for such an interface may be based
   on the 32-bit IPv4 address of an underlying interface, or formed
   using some other means, as long as it is unique from the other tunnel
   endpoint with a reasonably high probability.

http://tools.ietf.org/html/rfc4213


-- Wilco

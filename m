From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 19:11:46 +0100
Message-ID: <20130327181146.GB23223@order.stressinduktion.org>
References: <1364335457.8215.21.camel@localhost> <20130327151210.GA23223@order.stressinduktion.org> <1364398673.21709.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34519 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab3C0SLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:11:47 -0400
Content-Disposition: inline
In-Reply-To: <1364398673.21709.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 27, 2013 at 04:37:53PM +0100, Wilco Baan Hofman wrote:
> 
> On Wed, 2013-03-27 at 16:12 +0100, Hannes Frederic Sowa wrote:
> > On Tue, Mar 26, 2013 at 11:04:17PM +0100, Wilco Baan Hofman wrote:
> > > So I was wondering, is there any particular reason for the use of a /128
> > > link-local or is this just a bug?
> > 
> > Can you show me the commands how you set up the tunnel. It does create /64 ll
> > with embedded ipv4 addresses for me here on v3.8.
> > 
> 
> Weird, but sure, here goes:
> 
> ip tunnel add tunv6-uplink1 mode sit remote 192.168.1.1 local
> 192.168.1.21
> ip link set tunv6-uplink1 up mtu 1472

In my test I didn't specify the local address so addr.s6_addr32[3]
seems to be zero.  I'll have to search the RFCs why this is the case.

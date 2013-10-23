From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 10:12:55 +0200
Message-ID: <20131023081255.GB10148@secunet.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
 <20131001222002.GL10771@order.stressinduktion.org>
 <3928724.bDaZagpRh6@h2o.as.studentenwerk.mhn.de>
 <20131022.154638.1989281525248160764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@stwm.de, hannes@stressinduktion.org, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60304 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab3JWIM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 04:12:58 -0400
Content-Disposition: inline
In-Reply-To: <20131022.154638.1989281525248160764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 03:46:38PM -0400, David Miller wrote:
> From: Wolfgang Walter <linux@stwm.de>
> Date: Tue, 22 Oct 2013 21:07:41 +0200
> 
> > Am Mittwoch, 2. Oktober 2013, 00:20:02 schrieb Hannes Frederic Sowa:
> >> On Tue, Oct 01, 2013 at 06:39:32PM +0200, Wolfgang Walter wrote:
> >> > All network traffic over the router become slow and sluggish. If one pings
> >> > the router there is a packet loss. After about 2 minutes the traffic
> >> > completely stalls for about 1 minute. Then it works again as in the
> >> > beginning to then stall again. And so on.
> >> 
> >> Maybe dropwatch can give a first hint?
> >> 
> > 
> > I finally found the problem:
> > 
> > In 3.10.x and 3.11.x the value of /proc/sys/net/ipv4/xfrm4_gc_thresh is 1024.
> > 
> > It is much higher in 3.4.x. If I increase this value in 3.10.x to the one I 
> > see on 3.4.x all works fine with 3.10.x
> 
> Steffen, here is yet another report about this issue.
> 
> I think we should resolve this soon, even bumping it to 2048 or 4096
> and leaving it at that would be I think acceptable.
> 

Yes, of course. Let's use 4096 as the default for ipv4 and ipv6.
I'll take care of it next week.

Thanks!

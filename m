From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Fri, 7 Feb 2014 18:56:41 +0100
Message-ID: <20140207175641.GB16198@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38248 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbaBGR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 12:56:42 -0500
Content-Disposition: inline
In-Reply-To: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Feb 07, 2014 at 06:47:07PM +0100, Wolfgang Walter wrote:
> with kernel 3.13 I have a problem with isatap tunnels receiving fragmented 
> ipv6 udp packets.

Which was the last known version that did work? Also dropwatch and nstat could
give a first hint.

> If I switch of ufo for the tunnel device the problem disappears:
> 	ethtool -K is0 ufo off
> 
> When UFO is on tcpdump shows the packets on the physical device but not on the 
> tunnel device. The packets seem to be discarded.
> 
> With UFO off I can see them on is0 (and the packet is delivered to the 
> socket).

Thanks for the report, I'll look at it.

Greetings,

  Hannes

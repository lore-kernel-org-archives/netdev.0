From: Werner Almesberger <werner@almesberger.net>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Fri, 2 Aug 2013 01:51:27 -0300
Message-ID: <20130802045127.GA5594@ws>
References: <20130725061731.GA12365@order.stressinduktion.org>
 <20130725103048.GB29572@ws>
 <20130801054844.GC3688@order.stressinduktion.org>
 <20130801.181022.1784276332134390788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:51485 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab3HBExX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 00:53:23 -0400
Content-Disposition: inline
In-Reply-To: <20130801.181022.1784276332134390788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> FWIW I think this is a safe change.

Thanks !

Regarding the change to icmpv6.h, I found that the introduction
of the otherwise very nice and tidy "struct icmp6hdr_head" creates
a conflict with net/bridge/br_multicast.c:br_multicast_ipv6_rcv
which has a variable called "icmp6_type".

While it would be easy enough to rename that variable, this makes
me wonder if the change isn't too intrusive after all, I think
I'd rather go with my original idea and just change the size to 4,
with a comment why and what this is.

I'll post the patches in a bit.

- Werner

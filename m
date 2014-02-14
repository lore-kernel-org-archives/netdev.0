From: David Howells <dhowells@redhat.com>
Subject: Re: Does ICMP_FRAG_NEEDED automatically update the routing cache?
Date: Fri, 14 Feb 2014 15:42:53 +0000
Message-ID: <27629.1392392573@warthog.procyon.org.uk>
References: <20140214150328.GB27343@order.stressinduktion.org> <20140214144412.GA27343@order.stressinduktion.org> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660AbaBNPm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:42:57 -0500
In-Reply-To: <20140214150328.GB27343@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Yes, but connected sockets are checked prior to unconnected sockets, so the
> most specific one wins.
> 
> For unconnected ones only the local ip/port is checked because kernel
> does not know the past destination addresses.

Okay, thanks!

David

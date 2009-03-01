From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Sun, 01 Mar 2009 15:38:36 -0500
Message-ID: <1235939916.22828.7.camel@localhost.localdomain>
References: <1235324217.2832.49.camel@hashbaz.i.decadent.org.uk>
	 <20090226134950.GA975@decadentplace.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:53517 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbZCAUqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 15:46:04 -0500
In-Reply-To: <20090226134950.GA975@decadentplace.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-26 at 13:49 +0000, Ben Hutchings wrote:
> Based on a patch by Jaswinder Singh <jaswinder@infradead.org>.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

I suppose it's my fault for not getting around to this sooner, but I've
been waiting for the fallout to settle with tg3 and follow the leader.

Anyways, is it too much to ask for you to CC the maintainer? Hell, you
added a line right above my email address, so it wouldn't have been hard
for you to find...

I suppose I better test this sooner rather than later, because I think
you've broken it. The firmware gets vmalloc'd, which means it is not
necessarily physically contiguous, and I don't think pci_map_single() is
going to like that since the firmware is always larger than a page. But
I may be wrong on this.

Dave


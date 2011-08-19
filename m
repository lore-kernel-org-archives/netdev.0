From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 af-packet 0/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Fri, 19 Aug 2011 03:33:11 -0700 (PDT)
Message-ID: <20110819.033311.1204611705865122620.davem@davemloft.net>
References: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab1HSKdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:33:13 -0400
In-Reply-To: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Thu, 11 Aug 2011 22:30:58 -0400

> This patch attempts to:
> 1)Improve network capture visibility by increasing packet density
> 2)Assist in analyzing multiple(aggregated) capture ports.

Just some general comments before I say something about the actual
code.

Claiming loss-less, or almost loss-less, packet capture is something
which is highly dependent upon the hardware and traffic load.

You cannot claim near loss-less packet capture for an i386 with a
10gbit ethernet part going line rate, for example.

So I want you to describe this as what it is, an improvement.  More
specifically it's just a more flexible mmap ring buffer scheme that
reduces the wastage incurred by the fixed buffer size scheme we
have currently.

Next, you need to use a different subject line for the two patches.
Right now you say the same thing in both, and someone scanning the
changesets headers will have no idea what is different about one
change vs. the other.

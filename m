From: David Miller <davem@davemloft.net>
Subject: Re: Restricting payload size in do_tcp_sendpages.
Date: Thu, 01 Mar 2012 16:02:53 -0500 (EST)
Message-ID: <20120301.160253.995812674096452892.davem@davemloft.net>
References: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ashwin.shirvanthe@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932534Ab2CAVC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 16:02:56 -0500
In-Reply-To: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashwin Rao <ashwin.shirvanthe@gmail.com>
Date: Thu, 1 Mar 2012 16:16:40 +0100

> I would like to perform some experiments where I want TCP to send
> packets of size less than the MSS even more than an MSS worth of data
> is available in the TCP buffers.

I think if you are trying to make experimental changes to TCP you
should be at least skilled enough to implement your ideas fully on
your own rather than having to ask for a crash course on how the stack
works.

Frankly, if you aren't skilled enough to figure these things out on
your own I really don't think you should be even suggesting changes
to a complicated protocol that effects the entire world.

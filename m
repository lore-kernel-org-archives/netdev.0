From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 07 Oct 2013 17:34:33 -0400 (EDT)
Message-ID: <20131007.173433.163556658910279518.davem@davemloft.net>
References: <20131007.155214.2232375975382665567.davem@davemloft.net>
	<20131007212000.GA1596@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab3JGVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 17:34:35 -0400
In-Reply-To: <20131007212000.GA1596@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 7 Oct 2013 17:20:00 -0400

> Thats me experimenting.  I was thinking that origionally this functionality
> might be grouped separately, so that we could handle it independently of the
> standard network device operations (you might have noticed in v1 of my patch I
> had a size_t variable in there, so I thought the separation might be
> organizationally nice).  It was also something I was tinkering with for
> potential future work to support other data plane accelerators (like the FM6000
> switch chip from intel) in a manner that didn't pollute the more typical host network
> devices.  Like I said though, just experimenting at the moment....

Can these dataplane devices still act like a normal networking port and
send and receive packets at the host level?

If yes, that would be an extremely strong argument for netdev_ops.

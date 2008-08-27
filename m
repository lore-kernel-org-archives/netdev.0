From: Andi Kleen <andi@firstfloor.org>
Subject: Re: loaded router, excessive getnstimeofday in oprofile\
Date: Thu, 28 Aug 2008 00:38:28 +0200
Message-ID: <20080827223828.GD26610@one.firstfloor.org>
References: <20080827165635.GY26610@one.firstfloor.org> <48B58E6B.1030302@cosmosbay.com> <20080827183216.GZ26610@one.firstfloor.org> <20080827.152314.218610441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, dada1@cosmosbay.com, rick.jones2@hp.com,
	johnpol@2ka.mipt.ru, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55002 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbYH0Wfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:35:54 -0400
Content-Disposition: inline
In-Reply-To: <20080827.152314.218610441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is a much different kind of delay compared to sleeping for seconds
> or longer on the socket lock while a GFP_KERNEL allocation is being
> satisfied by swapping tons of crap out to disk.

When this happens then new incoming packets will be lost anyways
because there will be no new packets fed back into the RX ring
because their allocation will either stall or fail too.
I don't think time stamps of dropped packets are very useful ;-)

-Andi

-- 
ak@linux.intel.com

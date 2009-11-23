From: Robert Olsson <robert@herjulf.net>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 23:14:52 +0100
Message-ID: <19211.2396.896428.734183@gargle.gargle.HOWL>
References: <19210.54486.353397.804028@gargle.gargle.HOWL>
	<4B0ABF6D.9000103@gmail.com>
	<19210.63123.814368.292600@gargle.gargle.HOWL>
	<20091123.132823.162855593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, eric.dumazet@gmail.com, hawk@diku.dk,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-2-sn3.vrr.skanova.net ([81.228.9.186]:33425 "EHLO
	av9-2-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbZKWWfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:35:52 -0500
In-Reply-To: <20091123.132823.162855593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:
 > It seem very obvious to me that, for whatever reason, the MSI-X vectors
 > are only being sent to cpu 1 on Eric's system.
 > 
 > I also suspect, as a result, that it has nothing to do with the IXGBE
 > driver but rather is some IRQ controller programming or some bug or
 > limitation in the IRQ affinity mask handling in the kernel.

 Probably so yes. I'll guess Eric will dig into this.
 
 Cheers

					--ro
 
 

From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 13:28:23 -0800 (PST)
Message-ID: <20091123.132823.162855593.davem@davemloft.net>
References: <19210.54486.353397.804028@gargle.gargle.HOWL>
	<4B0ABF6D.9000103@gmail.com>
	<19210.63123.814368.292600@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hawk@diku.dk,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755098AbZKWV2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 16:28:05 -0500
In-Reply-To: <19210.63123.814368.292600@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: robert@herjulf.net
Date: Mon, 23 Nov 2009 21:54:43 +0100

>  Something mysterious or very obvious...

It seem very obvious to me that, for whatever reason, the MSI-X vectors
are only being sent to cpu 1 on Eric's system.

I also suspect, as a result, that it has nothing to do with the IXGBE
driver but rather is some IRQ controller programming or some bug or
limitation in the IRQ affinity mask handling in the kernel.

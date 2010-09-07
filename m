From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: b44 Handle RX FIFO overflow better (simplified)
Date: Mon, 06 Sep 2010 18:35:39 -0700 (PDT)
Message-ID: <20100906.183539.241915973.davem@davemloft.net>
References: <1283645879.1672.2.camel@corey>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-owner@vger.kernel.org, netdev@vger.kernel.org,
	James@superbug.co.uk
To: kernel@teksavvy.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755831Ab0IGBfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:35:22 -0400
In-Reply-To: <1283645879.1672.2.camel@corey>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Lord <kernel@teksavvy.com>
Date: Sat, 04 Sep 2010 20:17:59 -0400

> This patch is a simplified version of the original patch from James Courtier-Dutton.
> 
>>From: James Courtier-Dutton
>>Subject: [PATCH] Fix b44 RX FIFO overflow recovery.
>>Date: Wednesday, June 30, 2010 - 1:11 pm
>>
>>This patch improves the recovery after a RX FIFO overflow on the b44
>>Ethernet NIC.
>>Before it would do a complete chip reset, resulting is loss of link
>>for a few seconds.
>>This patch improves this to do recovery in about 20ms without loss of link.
>>
>>Signed off by: James@superbug.co.uk
> 
> Signed-off-by: Mark Lord <mlord@pobox.com>

Applied, thanks Mark.

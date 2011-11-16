From: David Miller <davem@davemloft.net>
Subject: Re: [PATCN net-next] net: use jump_label for netstamp_needed
Date: Wed, 16 Nov 2011 17:47:46 -0500 (EST)
Message-ID: <20111116.174746.405217012331368263.davem@davemloft.net>
References: <1321366375.2856.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab1KPWrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:47:48 -0500
In-Reply-To: <1321366375.2856.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Nov 2011 15:12:55 +0100

> netstamp_needed seems a good candidate to jump_label conversion.
> 
> This avoids 3 conditional branches per incoming packet in fast path.
> 
> No measurable difference, given that these conditional branches are
> predicted on modern cpus. Only a small icache reduction, thanks to the
> unlikely() stuff.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

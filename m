From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] packet: Add fanout support.
Date: Tue, 05 Jul 2011 09:08:44 -0700 (PDT)
Message-ID: <20110705.090844.483261881012193967.davem@davemloft.net>
References: <20110705.020419.1998951566353182397.davem@davemloft.net>
	<1309881840.2271.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab1GEQIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:08:51 -0400
In-Reply-To: <1309881840.2271.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2011 18:04:00 +0200

> There is a small window where __fanout_link(sk, po) is not yet called,
> but packets can be received on other cpus since dev_add_pack() was
> called.
> 
> There is no divide by 0, but fanout_demux_hash() can return a NULL sk,
> thus we can crash...

Indeed, you're right, I'll fix this.

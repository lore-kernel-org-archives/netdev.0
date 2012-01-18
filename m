From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix per device IP snmp counters
Date: Tue, 17 Jan 2012 23:56:27 -0500 (EST)
Message-ID: <20120117.235627.1727824865344348477.davem@davemloft.net>
References: <1326840336.2606.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757070Ab2ARE4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 23:56:30 -0500
In-Reply-To: <1326840336.2606.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2012 23:45:36 +0100

> In commit 4ce3c183fca (snmp: 64bit ipstats_mib for all arches), I forgot
> to change the /proc/net/dev_snmp6/xxx output for IP counters.
> 
> percpu array is 64bit per counter but the folding still used the 'long'
> variant, and output garbage on 32bit arches.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

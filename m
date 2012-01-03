From: David Miller <davem@davemloft.net>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Tue, 03 Jan 2012 14:48:13 -0500 (EST)
Message-ID: <20120103.144813.140566667824296408.davem@davemloft.net>
References: <20111228192150.GA16499@neilslaptop.think-freely.org>
	<20111228.143812.206477268839022030.davem@davemloft.net>
	<20120103194559.GB25184@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2ACTtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 14:49:19 -0500
In-Reply-To: <20120103194559.GB25184@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 3 Jan 2012 14:45:59 -0500

> Because of the above, we can compeltely ignore the manual address add path as
> far as the optimistic path is concerned.  Since we only call addrconf_prefix_rcv
> (where we add the SLAAC address), from ndisc_router_discovery (where we receive
> the new router advertisement, and parse its options), I think we can just
> augment addrconf_prefix_rcv with an extra parameter (a bool flag), which is set
> or cleared based on the value of the ND_OPT_SOURCE_LL_ADDR option in the ndopts
> array.  addrconf_prefix_rcv can use that flag to set or clear the optimistic
> flag.
> 
> Thoughts?

Sounds perfect, thanks Neil.

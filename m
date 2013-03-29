From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: add R-Car support for real
Date: Fri, 29 Mar 2013 15:31:53 -0400 (EDT)
Message-ID: <20130329.153153.139679960603982330.davem@davemloft.net>
References: <201303290051.32106.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, phil.edworthy@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756861Ab3C2Tbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:31:55 -0400
In-Reply-To: <201303290051.32106.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 29 Mar 2013 00:51:31 +0300

> Commit d0418bb7123f44b23d69ac349eec7daf9103472f (net: sh_eth: Add eth support
> for R8A7779 device) was a failed attempt to add support for one of members of
> the R-Car SoC family.  That's for three reasons: it treated R8A7779 the  same
> as SH7724 except including quite dirty hack adding ECMR_ELB  bit  to the mask
> in sh_eth_set_rate() while not removing ECMR_RTM bit (despite it's reserved in
> R-Car Ether), and it didn't add a new register offset array despite the closest
> SH_ETH_REG_FAST_SH4 mapping differs by 0x200 to the offsets all the R-Car Ether
> registers have, and also some of the registers in this old mapping don't exist
> on R-Car Ether (due to this, SH7724's 'sh_eth_my_cpu_data' structure is not
> adequeate for R-Car too).  Fix all these shortcomings, restoring the SH7724
> related section to its pristine state...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.

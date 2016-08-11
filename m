From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/1] rps: Inspect PPTP encapsulated by GRE to get
 flow hash
Date: Wed, 10 Aug 2016 17:24:50 -0700 (PDT)
Message-ID: <20160810.172450.1513266088290748091.davem@davemloft.net>
References: <1470717504-1292-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philipp@redfish-solutions.com, stephen@networkplumber.org,
	pshelar@nicira.com, tom@herbertland.com, aduyck@mirantis.com,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbcHKAYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:24:52 -0400
In-Reply-To: <1470717504-1292-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue,  9 Aug 2016 12:38:24 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The PPTP is encapsulated by GRE header with that GRE_VERSION bits
> must contain one. But current GRE RPS needs the GRE_VERSION must be
> zero. So RPS does not work for PPTP traffic.
> 
> In my test environment, there are four MIPS cores, and all traffic
> are passed through by PPTP. As a result, only one core is 100% busy
> while other three cores are very idle. After this patch, the usage
> of four cores are balanced well.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied to net-next, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: double default TSQ output bytes limit
Date: Thu, 04 Jun 2015 01:09:53 -0700 (PDT)
Message-ID: <20150604.010953.468723718124334903.davem@davemloft.net>
References: <1433326242-4061-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefano.stabellini@eu.citrix.com,
	george.dunlap@eu.citrix.com, eric.dumazet@gmail.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbbFDIJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:09:55 -0400
In-Reply-To: <1433326242-4061-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 3 Jun 2015 11:10:42 +0100

> Xen virtual network driver has higher latency than a physical NIC.
> Having only 128K as limit for TSQ introduced 30% regression in guest
> throughput.
> 
> This patch raises the limit to 256K. This reduces the regression to 8%.
> This buys us more time to work out a proper solution in the long run.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied, thanks.

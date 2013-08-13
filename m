From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_tunnel: Do not use inner ip-header-id for
 tunnel ip-header-id.
Date: Tue, 13 Aug 2013 16:53:23 -0700 (PDT)
Message-ID: <20130813.165323.387925674219585747.davem@davemloft.net>
References: <1376383266-6623-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jrajahalme@nicira.com, aatteka@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab3HMXxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:53:24 -0400
In-Reply-To: <1376383266-6623-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 13 Aug 2013 01:41:06 -0700

> Using inner-id for tunnel id is not safe in some rare cases.
> E.g. packets coming from multiple sources entering same tunnel
> can have same id. Therefore on tunnel packet receive we
> could have packets from two different stream but with same
> source and dst IP with same ip-id which could confuse ip packet
> reassembly.
> 
> Following patch reverts optimization from commit
> 490ab08127 (IP_GRE: Fix IP-Identification.)
> 
> CC: Jarno Rajahalme <jrajahalme@nicira.com>
> CC: Ansis Atteka <aatteka@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.

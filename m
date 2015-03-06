From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next 0/4] Improvements for TCP PMTU
Date: Fri, 06 Mar 2015 14:58:20 -0500 (EST)
Message-ID: <20150306.145820.1068836486161480022.davem@davemloft.net>
References: <1425611905-28503-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, edumazet@google.com, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbCFT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:58:22 -0500
In-Reply-To: <1425611905-28503-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Fri,  6 Mar 2015 11:18:21 +0800

> This patchset performs some improvements and enhancement
> for current TCP PMTU as per RFC4821 with the aim to find
> optimal mms size quickly, and also be adaptive to route
> changes like enlarged path MTU. Then TCP PMTU could be
> used to probe a effective pmtu in absence of ICMP message
> for tunnels(e.g. vxlan) across different networking stack.
> 
> Patch1/4: Set probe mss base to 1024 Bytes per RFC4821
> Patch2/4: Do not double probe_size for each probing,
>           use a simple binary search to gain maximum performance.
> 	  mss for next probing.
> Patch3/4: Create a probe timer to detect enlarged path MTU.
> Patch4/4: Update ip-sysctl.txt for new sysctl knobs.
> 
> Changelog:
 ...

Series applied, thanks.

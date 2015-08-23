From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] gro: Fixes for tunnels and GRO
Date: Sun, 23 Aug 2015 16:00:16 -0700 (PDT)
Message-ID: <20150823.160016.1377857025383633917.davem@davemloft.net>
References: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbHWXAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:00:17 -0400
In-Reply-To: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 19 Aug 2015 17:07:31 -0700

> This patch set addresses some issue related to tunneling and GRO:
> 
> - Fix remote checksum offload to properly deal with frag0 in GRO.
> - Add support for GRO at VXLAN tunnel (call gro_cells)
> 
> Testing: Ran one netperf TCP_STREAM to highlight impact of different
> configurations:
 ...

Looks fine, series applied, thanks Tom.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 00/11] net: expand time stamping, batch #2
Date: Mon, 20 Jun 2011 13:57:17 -0700 (PDT)
Message-ID: <20110620.135717.364300288585830864.davem@davemloft.net>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab1FTU5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:57:20 -0400
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 20 Jun 2011 09:51:22 +0200

> This patch series represents a continuation of the effort to get
> better coverage of the SO_TIMESTAMPING socket API in the Ethernet
> drivers.  Adding time stamping support to a given driver solves two
> separate issues, namely software transmit time stamping and hardware
> time stamping in PHY devices.
> 
> This second batch adds the hooks into all remaining (?) arm and
> powerpc MAC drivers using phylib. The first patch exports the receive
> hook for use by non-NAPI drivers when compiled as modules. Patch #5
> has been tested on real hardware, but the rest have only been compile
> tested.

All except patch #10 applied, thanks.

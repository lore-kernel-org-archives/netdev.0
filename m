From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 06 Jun 2012 21:34:03 -0400 (EDT)
Message-ID: <20120606.213403.1854035709991890835.davem@davemloft.net>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	<1339030752.2075.1.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shimoda.hiroaki@gmail.com, eric.dumazet@gmail.com,
	denys@visp.net.lb, therbert@google.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757466Ab2FGBeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 21:34:08 -0400
In-Reply-To: <1339030752.2075.1.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jun 2012 17:59:12 -0700

> This patch will cause unacceptable performance issues with non-ESB2
> parts.

You have to fix the regression a non-1 setting causes, performance
is secondary.

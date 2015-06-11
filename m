From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 2/2] Renesas Ethernet AVB PTP clock driver
Date: Thu, 11 Jun 2015 00:14:55 -0700 (PDT)
Message-ID: <20150611.001455.377939359927165224.davem@davemloft.net>
References: <2950738.iaDWZVkjG3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	linux-sh@vger.kernel.org, masaru.nagai.vx@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbFKHO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:14:56 -0400
In-Reply-To: <2950738.iaDWZVkjG3@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 11 Jun 2015 01:02:30 +0300

> Ethernet AVB device includes the gPTP  timer, so we can implement a PTP clock
> driver.  We're doing that in a separate file, with  the main Ethernet driver
> calling the PTP driver's [de]initialization and interrupt handler functions.
> Unfortunately, the clock seems tightly coupled with the AVB-DMAC, so when that
> one leaves the operation mode, we have to unregister the PTP clock... :-(
> 
> Based on the original patches by Masaru Nagai.
> 
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.

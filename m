From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: manage irq better on single port card
Date: Tue, 27 Sep 2011 00:51:15 -0400 (EDT)
Message-ID: <20110927.005115.2030295462342658475.davem@davemloft.net>
References: <20110923141340.39a8de91@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1I0EvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 00:51:17 -0400
In-Reply-To: <20110923141340.39a8de91@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 23 Sep 2011 14:13:40 -0700

> Most sky2 hardware only has a single port, although some variations of the
> chip support two interfaces.  For the single port case, use the standard
> Ethernet driver convention of allocating IRQ when device is brought up
> rather than at probe time.
> 
> Also, change the error handling of dual port cards so that if second
> port can not be brought up, then just fail. No point in continuing, since
> the failure is most certainly because of out of memory.
> 
> The dual port sky2 device has a single irq and a single status ring,
> therefore it has a single NAPI object shared by both ports.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.

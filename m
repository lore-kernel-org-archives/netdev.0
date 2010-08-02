From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Multiqueue macvtap driver
Date: Mon, 02 Aug 2010 14:29:03 +0100
Message-ID: <1280755743.2121.2.camel@achroite.uk.solarflarecom.com>
References: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>
	 <1280603907.13192.353.camel@localhost>
	 <20100801.003406.02275545.davem@davemloft.net>
	 <OF8519C301.F0E5FA07-ON65257772.004983CC-65257773.00453C8B@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arnd@arndb.de, mst@redhat.com,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43946 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0HBN3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 09:29:09 -0400
In-Reply-To: <OF8519C301.F0E5FA07-ON65257772.004983CC-65257773.00453C8B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-02 at 18:07 +0530, Krishna Kumar2 wrote:
> Thanks Ben & Dave. A question though - which of the following
> is preferable for the macvtap driver:
> 
> 1. Calculate flow and use that to find a queue; or
> 2. First check if skb_rx_queue_recorded is true and if so use
>     that; otherwise calculate the flow as in #1.
> 
> I guess #1 is better, since packets for a single flow will go to the
> same queue even if they arrive on different rxqs of a mq driver.
> But I want to make sure.
[...]

#2 is right.  Just as macvtap should provide a stable flow to RX-queue
mapping, so should the drivers it interfaces with.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Tue, 02 Feb 2010 17:40:45 -0800 (PST)
Message-ID: <20100202.174045.135005544.davem@davemloft.net>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
	<20100202.134251.15604523.davem@davemloft.net>
	<1265160242.15726.20.camel@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ktpedre@sandia.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932184Ab0BCBkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 20:40:32 -0500
In-Reply-To: <1265160242.15726.20.camel@hawkeye.sandia.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kevin Pedretti" <ktpedre@sandia.gov>
Date: Tue, 2 Feb 2010 18:24:02 -0700

> 4. Device only supports IPv4? -> Yes, that's correct. No IPv6 support.
> The driver squashes everything but IPv4 in eth2ss().

Not just IPV6, what about other ethernet protocols?

What about ARP?  How does IPV4 work if you only accept ETH_P_IP?  You
need to accept at least ETH_P_ARP for things to work.

> 2. May want to use alloc_netdev() -> Didn't do this. Would there be a
> substantial advantage to doing this?

I think you're going to end up having to make this change.

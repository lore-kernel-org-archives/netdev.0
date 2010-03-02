From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NETIF_F_FRAGLIST and NETIF_F_SG difference
Date: Tue, 02 Mar 2010 02:51:58 +0000
Message-ID: <1267498318.2819.21.camel@localhost>
References: <de0a9dcb1003010302p2f81aa17ubdbb29bb007d50cf@mail.gmail.com>
	 <1267448321.2819.15.camel@localhost>
	 <20100301.174024.214216263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mekaviraj@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12175 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab0CBCwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 21:52:03 -0500
In-Reply-To: <20100301.174024.214216263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-01 at 17:40 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 01 Mar 2010 12:58:41 +0000
> 
> > (I don't know why there are two ways of adding extra data.  The latter
> > does not seem to be used often.)
> 
> It's the most efficient way to handle IPv4/IPv6 fragmentation and
> reassembly.

But fragmentation results in a series of packets to be transmitted
separately (not gathered) and reassembly is only done at endpoints.  So
when would we see a fragment list on the transmit path?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


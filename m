From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Thu, 30 Jan 2014 15:21:16 +0100
Message-ID: <20140130142116.GD25336@order.stressinduktion.org>
References: <trinity-bc5263ea-896d-4350-aa80-fd2895b54b3b-1391084710336@3capp-gmx-bs28>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46875 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbaA3OVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 09:21:17 -0500
Content-Disposition: inline
In-Reply-To: <trinity-bc5263ea-896d-4350-aa80-fd2895b54b3b-1391084710336@3capp-gmx-bs28>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 01:25:10PM +0100, Simon Schneider wrote:
> Hi,
> for the scenarios
> - IPv4 over IPv4 IPsec tunnel
> - IPv6 over IPv4 IPsec tunnel
> 
> I wonder how the DF bit of the outer (encrypted) packet is set.
> 
> There are generally three options:
> - DF bit always 0
> - DF bit always 1
> - DF bit copied from inner packet

There is a pmtudisc knob on ip tunnel ... to force DF bit on outgoing packets,
but DF bit should get copied from inner packet up to tunnel header in every
case.

Greetings,

  Hannes

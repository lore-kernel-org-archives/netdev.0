From: Michael Barkowski <michaelbarkowski@ruggedcom.com>
Subject: Re: [PATCH] WAN: flush tx_queue in hdlc_ppp to prevent panic on rmmod
 hw_driver.
Date: Thu, 22 Apr 2010 15:17:13 -0400
Message-ID: <4BD0A0B9.2070709@ruggedcom.com>
References: <m3mxx5mv8v.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ruggedcom.com ([204.50.148.11]:11713 "EHLO
	mail2.ruggedcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab0DVTRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 15:17:15 -0400
In-Reply-To: <m3mxx5mv8v.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> tx_queue is used as a temporary queue when not allowed to queue skb
> directly to the hw device driver (which may sleep). Most paths flush
> it before returning, but ppp_start() currently cannot. Make sure we
> don't leave skbs pointing to a non-existent device.
> 
> Thanks to Michael Barkowski for reporting this problem.

Great - thanks.  Will this be going into -stable?

-- 
Michael Barkowski


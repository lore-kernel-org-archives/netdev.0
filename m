From: Rick Jones <rick.jones2@hp.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 09:56:06 -0700
Message-ID: <4A3BC326.4090203@hp.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Radha Mohan <radhamohan_ch@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:46446 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbZFSQ4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 12:56:06 -0400
In-Reply-To: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radha Mohan wrote:
> Hi,
> 
> For an ethernet driver, we need to allocate some pool of SKBs for
> receiving packets. Is there any way we can reuse the same SKBs
> without the need to re-allocate in atomic every time one has been
> used up for netif_rx().

Assuming a driver did have its own "pool" and didn't rely on the pool(s) 
from which skbs are drawn, doesn't that mean you have to now have 
another configuable?  There is no good guarantees on when the upper 
layers will be finished with the skb right?  Which means you would be 
requiring the admin(s) to have an idea of how long their applications 
wait to pull data from their sockets and configure your driver accordingly.

It would seem there would have to be a considerable performance gain 
demonstrated for that kind of thing?

rick jones

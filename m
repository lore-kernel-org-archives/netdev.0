From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/3] Uninline the __inet_lookup_established
 function
Date: Thu, 20 Dec 2007 15:32:24 -0800 (PST)
Message-ID: <20071220.153224.258648937.davem@davemloft.net>
References: <4768F834.3060100@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54472
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbXLTXcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:32:24 -0500
In-Reply-To: <4768F834.3060100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 19 Dec 2007 13:53:40 +0300

> This is -700 bytes from the net/ipv4/built-in.o
> 
> add/remove: 1/0 grow/shrink: 1/3 up/down: 340/-1040 (-700)
> function                                     old     new   delta
> __inet_lookup_established                      -     339    +339
> tcp_sacktag_write_queue                     2254    2255      +1
> tcp_v4_err                                  1304     973    -331
> tcp_v4_rcv                                  2089    1744    -345
> tcp_v4_do_rcv                                826     462    -364
> 
> Exporting is for dccp module (used via e.g. inet_lookup).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

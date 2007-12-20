From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 (resend) 1/3] Uninline the __inet_hash
 function
Date: Thu, 20 Dec 2007 15:31:43 -0800 (PST)
Message-ID: <20071220.153143.44884827.davem@davemloft.net>
References: <476951A8.4040200@cosmosbay.com>
	<20071220.003027.20529103.davem@davemloft.net>
	<476A39DF.5080604@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbXLTXbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:31:44 -0500
In-Reply-To: <476A39DF.5080604@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 20 Dec 2007 12:46:07 +0300

> This one is used in quite many places in the networking code and
> seems to big to be inline.
> 
> After the patch net/ipv4/build-in.o loses ~650 bytes:
> add/remove: 2/0 grow/shrink: 0/5 up/down: 461/-1114 (-653)
> function                                     old     new   delta
> __inet_hash_nolisten                           -     282    +282
> __inet_hash                                    -     179    +179
> tcp_sacktag_write_queue                     2255    2254      -1
> __inet_lookup_listener                       284     274     -10
> tcp_v4_syn_recv_sock                         755     493    -262
> tcp_v4_hash                                  389      35    -354
> inet_hash_connect                           1086     599    -487
> 
> This version addresses the issue pointed by Eric, that
> while being inline this function was optimized by gcc
> in respect to the 'listen_possible' argument.
> 
> (Patches 2 and 3 in this series are still applied after this)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

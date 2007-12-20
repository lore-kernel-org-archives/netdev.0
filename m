From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3] Uninline the inet_twsk_put function
Date: Thu, 20 Dec 2007 15:33:16 -0800 (PST)
Message-ID: <20071220.153316.49150295.davem@davemloft.net>
References: <4768F8CD.2050209@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752868AbXLTXdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:33:17 -0500
In-Reply-To: <4768F8CD.2050209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 19 Dec 2007 13:56:13 +0300

> This one is not that big, but is widely used: saves 1200 bytes 
> from net/ipv4/built-in.o
> 
> add/remove: 1/0 grow/shrink: 1/12 up/down: 97/-1300 (-1203)
> function                                     old     new   delta
> inet_twsk_put                                  -      87     +87
> __inet_lookup_listener                       274     284     +10
> tcp_sacktag_write_queue                     2255    2254      -1
> tcp_time_wait                                482     411     -71
> __inet_check_established                     796     722     -74
> tcp_v4_err                                   973     898     -75
> __inet_twsk_kill                             230     154     -76
> inet_twsk_deschedule                         180     103     -77
> tcp_v4_do_rcv                                462     384     -78
> inet_hash_connect                            686     607     -79
> inet_twdr_do_twkill_work                     236     150     -86
> inet_twdr_twcal_tick                         395     307     -88
> tcp_v4_rcv                                  1744    1480    -264
> tcp_timewait_state_process                   975     644    -331
> 
> Export it for ipv6 module.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.

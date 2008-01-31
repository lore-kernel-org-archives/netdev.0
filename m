From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6][INET]: Consolidate inet(6)_hash_connect.
Date: Thu, 31 Jan 2008 05:04:58 -0800 (PST)
Message-ID: <20080131.050458.76874576.davem@davemloft.net>
References: <47A1BFC9.2030603@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764892AbYAaNEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:04:37 -0500
In-Reply-To: <47A1BFC9.2030603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:32:09 +0300

> These two functions are the same except for what they call
> to "check_established" and "hash" for a socket.
> 
> This saves half-a-kilo for ipv4 and ipv6.
> 
>  add/remove: 1/0 grow/shrink: 1/4 up/down: 582/-1128 (-546)
>  function                                     old     new   delta
>  __inet_hash_connect                            -     577    +577
>  arp_ignore                                   108     113      +5
>  static.hint                                    8       4      -4
>  rt_worker_func                               376     372      -4
>  inet6_hash_connect                           584      25    -559
>  inet_hash_connect                            586      25    -561
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

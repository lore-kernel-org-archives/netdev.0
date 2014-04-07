From: David Miller <davem@davemloft.net>
Subject: Re: net/l2tp/l2tp_ppp.c should take pmtu from tunnel socket
Date: Mon, 07 Apr 2014 15:07:30 -0400 (EDT)
Message-ID: <20140407.150730.744205365492439471.davem@davemloft.net>
References: <CAP6LPsDCgCCxRhF4Pc+JZu_ZRou9RJ6SEEyk6Sa2sxtbqs_Gog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmgenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711AbaDGTHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 15:07:31 -0400
In-Reply-To: <CAP6LPsDCgCCxRhF4Pc+JZu_ZRou9RJ6SEEyk6Sa2sxtbqs_Gog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Petukhov <dmgenp@gmail.com>
Date: Sun, 6 Apr 2014 00:58:27 +0600

> currently when it tries to get PMTU, it does
> 
> dst = sk_dst_get(sk);
> ...
> u32 pmtu = dst_mtu(__sk_dst_get(sk));
> 
> where sk represents PPPoX socket
> 
> it should use tunnel UDP socket instead, tunnel->sock
> 
> This bug bite me when I tried to use l2tp vpn over the link with mtu <
> 1500 but where fragments were dropped somewere along the path. I tried
> to use this mechanism with
> 
> ip route add <dst> via ... mtu <lower_mtu>
> 
> but it didn't work.
> 
> After the fix I was able to use this feature of l2tp_ppp driver, it
> picked up mtu set by ip route and used it.
> 
> patch against https://github.com/torvalds/linux master:

This is not a proper patch submission, please read Documentation/SubmittingPatches
to learn how to do it properly.

In particular, you need to provide a proper patch signoff.

Please do not reply to this thread with the updated patch submission,
instead make a new, fresh, list posting following the patch submission
rules.

Thanks.

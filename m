From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV6]: Mischecked tw match in
 __inet6_check_established.
Date: Tue, 15 Jan 2008 03:33:43 -0800 (PST)
Message-ID: <20080115.033343.80000789.davem@davemloft.net>
References: <478C7B6C.3030002@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbYAOLdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 06:33:44 -0500
In-Reply-To: <478C7B6C.3030002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 15 Jan 2008 12:22:52 +0300

> When looking for a conflicting connection the !sk->sk_bound_dev_if
> check is performed only for live sockets, but not for timewait-ed.
> 
> This is not the case for ipv4, for __inet6_lookup_established in
> both ipv4 and ipv6 and for other places that check for tw-s.
> 
> Was this missed accidentally? If so, then this patch fixes it and
> besides makes use if the dif variable declared in the function.
> 
> Fits both, net-2.6 and net-2.6.25.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This fix definitely looks correct.

I just sent Linus a pull request for other 2.6.24 fixes,
so I'll toss this into my net-2.6 tree tomorrow after
he pulls that stuff in.

Thanks!


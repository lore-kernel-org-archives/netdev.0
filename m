From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v4] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Wed, 22 Mar 2017 21:55:04 -0600
Message-ID: <8d5e22e0bd21739b1d4ea21703ffde7d@codeaurora.org>
References: <1490234441-19341-1-git-send-email-subashab@codeaurora.org>
 <20170322.194357.531371967824197040.davem@davemloft.net>
 <20170322.203618.972117086361436133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stephen@networkplumber.org, tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45096 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdCWDzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 23:55:06 -0400
In-Reply-To: <20170322.203618.972117086361436133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This doesn't build with ipv6 as a module:
> 
> net/built-in.o: In function `proc_tcp_early_demux':
> sysctl_net_ipv4.c:(.text+0x145cfc): undefined reference to
> `tcp_v6_early_demux_configure'
> net/built-in.o: In function `proc_udp_early_demux':
> sysctl_net_ipv4.c:(.text+0x145d4c): undefined reference to
> `udp_v6_early_demux_configure'
> Makefile:983: recipe for target 'vmlinux' failed

Hi David

Sorry about that (we always have IPV6 enabled).
Do I have to send a v5 or separate patch for this?

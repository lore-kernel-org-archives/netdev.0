From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] udpv6: reset daddr and dport in sk if connect()
 fails
Date: Fri, 23 Jun 2017 14:03:43 -0400 (EDT)
Message-ID: <20170623.140343.1430137406292396677.davem@davemloft.net>
References: <20170622190341.87998-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, maze@google.com, subashab@codeaurora.org,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753397AbdFWSDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:03:45 -0400
In-Reply-To: <20170622190341.87998-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Thu, 22 Jun 2017 12:03:41 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In __ip6_datagram_connect(), reset sk->sk_v6_daddr and inet->dport if
> error occurs so that udp_v6_early_demux() won't consider this socket
> as a valid candidate for early demux.
> 
> v2: fix compilation error
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Maciej ¯enczykowski <maze@google.com>

Please also add a state test against TCP_ESTABLISHED in UDP v6 early
demux to close this race completely.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: pass up EMSGSIZE msg for UDP socket in
 Ipv6
Date: Fri, 19 Feb 2016 15:47:12 -0500 (EST)
Message-ID: <20160219.154712.457066043473867991.davem@davemloft.net>
References: <1455746302-53543-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946140AbcBSUrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:47:14 -0500
In-Reply-To: <1455746302-53543-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Wed, 17 Feb 2016 13:58:22 -0800

> From: Wei Wang <weiwan@google.com>
> 
> In ipv4,  when  the machine receives a ICMP_FRAG_NEEDED message,  the
> connected UDP socket will get EMSGSIZE message on its next read from the
> socket.
> However, this is not the case for ipv6.
> This fix modifies the udp err handler in Ipv6 for ICMP6_PKT_TOOBIG to
> make it similar to ipv4 behavior. That is when the machine gets an
> ICMP6_PKT_TOOBIG message, the connected UDP socket will get EMSGSIZE
> message on its next read from the socket.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 04 Feb 2012 18:20:28 -0500 (EST)
Message-ID: <20120204.182028.309520370369346156.davem@davemloft.net>
References: <RE:_[PATCH]_tcp_v4_send_reset:_binding_oif_to_iif_in_no_sock_case>
	<1328395089-15932-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: shawn.lu@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035Ab2BDXUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 18:20:37 -0500
In-Reply-To: <1328395089-15932-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Lu <shawn.lu@ericsson.com>
Date: Sat, 4 Feb 2012 14:38:09 -0800

> Binding RST packet outgoing interface to incoming interface
> for tcp v4 when there is no socket associate with it.
> when sk is not NULL, using sk->sk_bound_dev_if instead.
> (suggested by Eric Dumazet).
> 
> This has few benefits:
> 1. tcp_v6_send_reset already did that.
> 2. This helps tcp connect with SO_BINDTODEVICE set. When
> connection is lost, we still able to sending out RST using
> same interface.
> 3. we are sending reply, it is most likely to be succeed
> if iif is used
> 
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.

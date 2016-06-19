From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] ipv6: better traceroute support in sit
 and gre
Date: Sat, 18 Jun 2016 22:11:54 -0700 (PDT)
Message-ID: <20160618.221154.2007194614234235433.davem@davemloft.net>
References: <1466311926-27167-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ghorbel@pivasoftware.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbcFSFL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 01:11:57 -0400
In-Reply-To: <1466311926-27167-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat, 18 Jun 2016 21:52:01 -0700

> In commit ca15a078bd90 ("sit: generate icmpv6 error when receiving icmpv4
> error"), Oussama Ghorbel added minimal support for SIT tunnels to
> generate ICMPv6 messages when receiving ICMPv4 messages.
> 
> This patch series extends this to GRE tunnels.
> 
> It also adds support for ICMPV6_TIME_EXCEED.
> 
> Partial support for RFC 4884 is added, to forward ICMP Multi-part
> extensions eventually found in the ICMPv4 message.
> 
> v2: replaced an overlapping memcpy() by memmove()

Series applied, thanks Eric.

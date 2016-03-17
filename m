From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Wed, 16 Mar 2016 22:38:03 -0400 (EDT)
Message-ID: <20160316.223803.240230703927987310.davem@davemloft.net>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	<20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiwan@google.com, edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965811AbcCQCiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 22:38:07 -0400
In-Reply-To: <1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2016 17:22:07 -0700

> One of the issue is that IPV6_MTU getsockopt() will not check the dst,
> but simply use __sk_dst_get() : It will then report old mtu.

That's a bug.

ipv4 does it right with a proper sk_dst_get() and so should
ipv6.

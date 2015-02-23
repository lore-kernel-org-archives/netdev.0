From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] igmp v6: add __ipv6_sock_mc_join and
 __ipv6_sock_mc_drop
Date: Mon, 23 Feb 2015 07:16:24 -0800
Message-ID: <1424704584.5565.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424672814-2998-1-git-send-email-challa@noironetworks.com>
	 <1424672814-2998-2-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:55950 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbBWPQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 10:16:26 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so18803506igb.2
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 07:16:26 -0800 (PST)
In-Reply-To: <1424672814-2998-2-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-02-22 at 22:26 -0800, Madhu Challa wrote:
> Based on the igmp v4 changes from Eric Dumazet.
> 959d10f6bbf6ab5b8813c4e37540a2e43ca2ae96
> 
> These changes are needed to perform igmp v6 join/leave while
> RTNL is held.
> 
> Make ipv6_sock_mc_join and ipv6_sock_mc_drop wrappers around
> __ipv6_sock_mc_join and  __ipv6_sock_mc_drop to avoid
> proliferation of work queues.
> 
> Signed-off-by: Madhu Challa <challa@noironetworks.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

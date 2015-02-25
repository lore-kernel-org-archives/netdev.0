From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] igmp v6: add __ipv6_sock_mc_join and
 __ipv6_sock_mc_drop
Date: Wed, 25 Feb 2015 10:41:28 -0800
Message-ID: <1424889688.5565.115.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
	 <1424887115-3483-2-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, daniel@iogearbox.net, netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:56333 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbBYSla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:41:30 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so8254602igb.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 10:41:29 -0800 (PST)
In-Reply-To: <1424887115-3483-2-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 09:58 -0800, Madhu Challa wrote:
> Based on the igmp v4 changes from Eric Dumazet.
> 959d10f6bbf6("igmp: add __ip_mc_{join|leave}_group()")
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

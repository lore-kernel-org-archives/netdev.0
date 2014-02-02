From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V1] net/ipv4: Use proper RCU APIs for writer-side in
 udp_offload.c
Date: Sun, 02 Feb 2014 10:49:35 -0800
Message-ID: <1391366975.28432.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391348530-31643-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:57974 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbaBBSti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 13:49:38 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so2858187igb.3
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 10:49:38 -0800 (PST)
In-Reply-To: <1391348530-31643-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-02 at 15:42 +0200, Or Gerlitz wrote:
> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> RCU writer side should use rcu_dereference_protected() and not
> rcu_dereference(), fix that. This also removes the "suspicious RCU usage"
> warning seen when running with CONFIG_PROVE_RCU.
> 
> Also, don't use rcu_assign_pointer/rcu_dereference for pointers
> which are invisible beyond the udp offload code.
> 
> Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
> Reported-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V1 00/14] net/mlx4_en: Optimizations to TX flow
Date: Mon, 06 Oct 2014 05:51:44 -0700
Message-ID: <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:38455 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbaJFMvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 08:51:46 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so5150470pad.8
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 05:51:46 -0700 (PDT)
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 09:15 +0300, Amir Vadai wrote:

> Changes from V0:
> - Patch 14/14 ("Use the new tx_copybreak to set inline threshold"):
>   - Use same coding convention as currently is in en_ethtool.c
> - Patch 1/14 ("Code cleanups in tx path") and Patch 9/14 ("Use local var in
>   tx flow for skb_shinfo(skb)"):
>   - local var shinfo was used by mistake in Patch 1/14 while declared at 9/14.
>     Fixed it for the sake of future bisections

Hmm... patches were already merged. I am afraid you need to provide one
patch on top of current net-next, if still needed. Too bad for the
bisection.

Thanks !

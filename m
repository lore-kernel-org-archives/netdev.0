From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 21:17:24 -0500 (EST)
Message-ID: <20170110.211724.1334303329696530105.davem@davemloft.net>
References: <1484070109-105991-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, tariqt@mellanox.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935831AbdAKCR0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:17:26 -0500
In-Reply-To: <1484070109-105991-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 10 Jan 2017 09:41:49 -0800

> In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
> it changed EOPNOTSUPP to ENOTSUPP by mistake.  This patch fixes it.
> 
> Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.

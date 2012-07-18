From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Statically initialize init_net.dev_base_head
Date: Wed, 18 Jul 2012 21:13:29 +0200
Message-ID: <1342638809.2626.3451.camel@edumazet-glaptop>
References: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com
To: Mark Rustad <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:65245 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282Ab2GRTNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:13:35 -0400
Received: by qaas11 with SMTP id s11so1239051qaa.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 12:13:34 -0700 (PDT)
In-Reply-To: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 12:06 -0700, Mark Rustad wrote:
> This change eliminates an initialization-order hazard most
> recently seen when netprio_cgroup is built into the kernel.
> 
> With thanks to Eric Dumazet for catching a bug.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> ---
> 
>  net/core/dev.c           |    3 ++-
>  net/core/net_namespace.c |    4 +++-
>  2 files changed, 5 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: perform DMA to userspace only if there is a task
 waiting for it
Date: Fri, 27 Jul 2012 13:31:35 -0700 (PDT)
Message-ID: <20120727.133135.2017747630291360657.davem@davemloft.net>
References: <alpine.LNX.2.00.1207271556320.11375@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jbohac@suse.cz
To: jkosina@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1207271556320.11375@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Fri, 27 Jul 2012 16:05:06 +0200 (CEST)

>  #ifdef CONFIG_NET_DMA
> -				if (tcp_dma_try_early_copy(sk, skb, tcp_header_len)) {
> +				if (tp->ucopy.task == current &&
> +						sock_owned_by_user(sk) &&
> +						tcp_dma_try_early_copy(sk,
> +							skb, tcp_header_len)) {

This indentation is absolutely terrible.

If you are only able to indent lines using TAB characters, rather than
using an appropriate mixture of TAB and SPACE characters to get the
lines to line up properly, please do not even bother submitting
patches here.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: #ifdefify sk_classid member of struct
 sock
Date: Tue, 21 Jul 2015 16:04:49 -0700 (PDT)
Message-ID: <20150721.160449.1252007154160791449.davem@davemloft.net>
References: <1437337273-16775-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGUXEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:04:50 -0400
In-Reply-To: <1437337273-16775-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 22:21:13 +0200

> The sk_classid member is only required when CONFIG_CGROUP_NET_CLASSID is
> enabled. #ifdefify it to reduce the size of struct sock on 32 bit
> systems, at least.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
> v2:
> - ensure we'll error out in nft_meta_get_init() if CONFIG_CGROUP_NET_CLASSID
>   is not set

Applied, thanks.

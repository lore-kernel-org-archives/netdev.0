From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/2] ipv6: fix ip6_tnl_parse_tlv_enc_lim() issues
Date: Tue, 24 Jan 2017 14:54:01 -0500 (EST)
Message-ID: <20170124.145401.1164225343344688380.davem@davemloft.net>
References: <20170124004306.19236-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, ast@kernel.org,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdAXTyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:54:05 -0500
In-Reply-To: <20170124004306.19236-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 23 Jan 2017 16:43:04 -0800

> First patch fixes ip6_tnl_parse_tlv_enc_lim() callers,
> bug added in linux-3.7
> 
> Second patch fixes ip6_tnl_parse_tlv_enc_lim() itself,
> bug predates linux-2.6.12
> 
> Based on a report from Dmitry Vyukov, thanks to KASAN.

Series applied and queued up for -stable, thanks Eric.

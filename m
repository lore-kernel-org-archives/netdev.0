From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bpf: Fix bpf_redirect to an ipip/ip6tnl dev
Date: Sat, 12 Nov 2016 23:39:12 -0500 (EST)
Message-ID: <20161112.233912.1404421746993270582.davem@davemloft.net>
References: <1478734594-337666-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932268AbcKMEjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 23:39:16 -0500
In-Reply-To: <1478734594-337666-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 9 Nov 2016 15:36:32 -0800

> This patch set fixes a bug in bpf_redirect(dev, flags) when dev is an
> ipip/ip6tnl.  The current problem is IP-EthHdr-IP is sent out instead of
> IP-IP.
> 
> Patch 1 adds a dev->type test similar to dev_is_mac_header_xmit()
> in act_mirred.c which is only available in net-next.  We can consider to
> refactor it once this patch is pulled into net-next from net.

Series applied, thanks Martin.

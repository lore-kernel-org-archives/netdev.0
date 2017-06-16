From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/9] bpf: xdp: Report bpf_prog ID in
 IFLA_XDP
Date: Fri, 16 Jun 2017 11:59:28 -0400 (EDT)
Message-ID: <20170616.115928.1848639816473502604.davem@davemloft.net>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFPP7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:59:45 -0400
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 15 Jun 2017 17:29:08 -0700

> This is the first usage of the new bpf_prog ID.  It is for
> reporting the ID of a xdp_prog through netlink.
> 
> It rides on the existing IFLA_XDP.  This patch adds IFLA_XDP_PROG_ID
> for the bpf_prog ID reporting.
> 
> It starts with changing the generic_xdp first.  After that,
> the hardware driver is changed one by one.  Jakub Kicinski mentioned
> that he will soon introduce XDP_ATTACHED_HW (on top of the existing
> XDP_ATTACHED_DRV and XDP_ATTACHED_SKB)
> and he is going to reuse the prog_attached for this purpose.
> Hence, this patch set keeps the prog_attached even though
> !!prog_id also implies there is xdp_prog attached.
> 
> I have tested with generic_xdp, mlx4 and mlx5.
 ...

Series applied, thanks Martin.

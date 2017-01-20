From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bpf: fix samples xdp_tx_iptunnel and
 tc_l2_redirect with fake KBUILD_MODNAME
Date: Fri, 20 Jan 2017 12:04:43 -0500 (EST)
Message-ID: <20170120.120443.1159212475181260259.davem@davemloft.net>
References: <148475634058.19645.17347886661194782120.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net, kafai@fb.com,
        alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdATRP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:15:58 -0500
In-Reply-To: <148475634058.19645.17347886661194782120.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 18 Jan 2017 17:19:00 +0100

> Fix build errors for samples/bpf xdp_tx_iptunnel and tc_l2_redirect,
> when dynamic debugging is enabled (CONFIG_DYNAMIC_DEBUG) by defining a
> fake KBUILD_MODNAME.
> 
> Just like Daniel Borkmann fixed other samples/bpf in commit
> 96a8eb1eeed2 ("bpf: fix samples to add fake KBUILD_MODNAME").
> 
> Fixes: 12d8bb64e3f6 ("bpf: xdp: Add XDP example for head adjustment")
> Fixes: 90e02896f1a4 ("bpf: Add test for bpf_redirect to ipip/ip6tnl")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.

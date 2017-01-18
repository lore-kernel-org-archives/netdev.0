From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net PATCH] bpf: fix samples xdp_tx_iptunnel and tc_l2_redirect
 with fake KBUILD_MODNAME
Date: Wed, 18 Jan 2017 17:23:17 +0100
Message-ID: <587F9675.1090303@iogearbox.net>
References: <148475634058.19645.17347886661194782120.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54847 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753943AbdARQXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 11:23:19 -0500
In-Reply-To: <148475634058.19645.17347886661194782120.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 05:19 PM, Jesper Dangaard Brouer wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

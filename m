From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH] bpf: fix samples xdp_tx_iptunnel and tc_l2_redirect
 with fake KBUILD_MODNAME
Date: Wed, 18 Jan 2017 08:38:15 -0800
Message-ID: <20170118163813.GA55940@ast-mbp.thefacebook.com>
References: <148475634058.19645.17347886661194782120.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <borkmann@iogearbox.net>,
        kafai@fb.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36765 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbdARQia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 11:38:30 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so1436542pfo.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 08:38:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <148475634058.19645.17347886661194782120.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 05:19:00PM +0100, Jesper Dangaard Brouer wrote:
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

Thanks for the fix!
Acked-by: Alexei Starovoitov <ast@kernel.org>

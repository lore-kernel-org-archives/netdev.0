From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 1/2] samples/bpf: fix SKB_MODE flag to be a 32-bit
 unsigned int
Date: Mon, 01 May 2017 11:55:38 +0200
Message-ID: <5907061A.9070409@iogearbox.net>
References: <149363073213.17600.4480290736818479957.stgit@firesoul> <149363077553.17600.5609466598508053296.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35333 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426142AbdEAJzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 05:55:43 -0400
In-Reply-To: <149363077553.17600.5609466598508053296.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2017 11:26 AM, Jesper Dangaard Brouer wrote:
> The kernel side of XDP_FLAGS_SKB_MODE is unsigned, and the rtnetlink
> IFLA_XDP_FLAGS is defined as NLA_U32. Thus, userspace programs under
> samples/bpf/ should use the correct type.
>
> Fixes: 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

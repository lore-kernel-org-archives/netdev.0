From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 2/2] samples/bpf: fix XDP_FLAGS_SKB_MODE detach
 for xdp_tx_iptunnel
Date: Mon, 01 May 2017 11:56:15 +0200
Message-ID: <5907063F.8090504@iogearbox.net>
References: <149363073213.17600.4480290736818479957.stgit@firesoul> <149363078062.17600.11958698183756401134.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35388 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426736AbdEAJ4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 05:56:19 -0400
In-Reply-To: <149363078062.17600.11958698183756401134.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2017 11:26 AM, Jesper Dangaard Brouer wrote:
> The xdp_tx_iptunnel program can be terminated in two ways, after
> N-seconds or via Ctrl-C SIGINT.  The SIGINT code path does not
> handle detatching the correct XDP program, in-case the program
> was attached with XDP_FLAGS_SKB_MODE.
>
> Fix this by storing the XDP flags as a global variable, which is
> available for the SIGINT handler function.
>
> Fixes: 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

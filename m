From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Thu, 08 Dec 2016 10:02:37 +0100
Message-ID: <584921AD.3060004@iogearbox.net>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com> <1481154794-2311034-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56942 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbcLHJCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 04:02:42 -0500
In-Reply-To: <1481154794-2311034-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2016 12:53 AM, Martin KaFai Lau wrote:
> This patch allows XDP prog to extend/remove the packet
> data at the head (like adding or removing header).  It is
> done by adding a new XDP helper bpf_xdp_adjust_head().
>
> It also renames bpf_helper_changes_skb_data() to
> bpf_helper_changes_pkt_data() to better reflect
> that XDP prog does not work on skb.
>
> This patch adds one "xdp_adjust_head" bit to bpf_prog for the
> XDP-capable driver to check if the XDP prog requires
> bpf_xdp_adjust_head() support.  The driver can then decide
> to error out during XDP_SETUP_PROG.
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Sun, 04 Dec 2016 16:11:07 +0100
Message-ID: <5844320B.2000502@iogearbox.net>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com> <1480821446-4122277-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60396 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751111AbcLDPLL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 10:11:11 -0500
In-Reply-To: <1480821446-4122277-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2016 04:17 AM, Martin KaFai Lau wrote:
> This patch allows XDP prog to extend/remove the packet
> data at the head (like adding or removing header).  It is
> done by adding a new XDP helper bpf_xdp_adjust_head().
>
> It also renames bpf_helper_changes_skb_data() to
> bpf_helper_changes_pkt_data() to better reflect
> that XDP prog does not work on skb.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Yeah, looks good like that:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Should there one day be different requirements wrt min length,
we could always pass dev pointer via struct xdp_buff and then
use dev->hard_header_len, for example, but not needed right now.

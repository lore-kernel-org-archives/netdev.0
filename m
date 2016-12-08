From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Thu, 8 Dec 2016 08:55:17 -0800
Message-ID: <20161208165515.GA92599@ast-mbp.thefacebook.com>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com>
 <1481154794-2311034-2-git-send-email-kafai@fb.com>
 <584921AD.3060004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35563 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLHQzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:55:23 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so13190289pfk.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 08:55:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <584921AD.3060004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 10:02:37AM +0100, Daniel Borkmann wrote:
> On 12/08/2016 12:53 AM, Martin KaFai Lau wrote:
> >This patch allows XDP prog to extend/remove the packet
> >data at the head (like adding or removing header).  It is
> >done by adding a new XDP helper bpf_xdp_adjust_head().
> >
> >It also renames bpf_helper_changes_skb_data() to
> >bpf_helper_changes_pkt_data() to better reflect
> >that XDP prog does not work on skb.
> >
> >This patch adds one "xdp_adjust_head" bit to bpf_prog for the
> >XDP-capable driver to check if the XDP prog requires
> >bpf_xdp_adjust_head() support.  The driver can then decide
> >to error out during XDP_SETUP_PROG.
> >
> >Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>

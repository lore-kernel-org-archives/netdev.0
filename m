From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v4 net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Thu, 8 Dec 2016 20:36:14 +0200
Message-ID: <CALzJLG_biMj-KKqi14iARegR_vhYwT4671CcksgnLQUcTPKnGw@mail.gmail.com>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com> <1481154794-2311034-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34318 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLHSgg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:36:36 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so5310484wme.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:36:35 -0800 (PST)
In-Reply-To: <1481154794-2311034-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 1:53 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> When XDP is active in mlx4, mlx4 is using one page/pkt.
> At the same time (i.e. when XDP is active), it is currently
> limiting MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN)
> which is 1514 in x86.  AFAICT, we can at least raise the MTU
> limit up to PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this
> patch is doing.  It will be useful in the next patch which
> allows XDP program to extend the packet by adding new header(s).
>
> Note: In the earlier XDP patches, there is already existing guard
> to ensure the page/pkt scheme only applies when XDP is active
> in mlx4.
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>

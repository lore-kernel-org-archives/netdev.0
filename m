From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Fri, 02 Dec 2016 19:59:28 -0800
Message-ID: <1480737568.18162.398.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
         <1480721013-1047541-3-git-send-email-kafai@fb.com>
         <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
         <58421775.6090905@fb.com>
         <1480731326.18162.397.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161203034232.GA70461@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36131 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLCD7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 22:59:31 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so9706674pgx.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 19:59:31 -0800 (PST)
In-Reply-To: <20161203034232.GA70461@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 19:42 -0800, Martin KaFai Lau wrote:
> On Fri, Dec 02, 2016 at 06:15:26PM -0800, Eric Dumazet wrote:
> > My question was more like :
> >
> > Can we double check all these patches wont break mlx4 driver (non XDP
> > path) on arches with PAGE_SIZE=64KB.
> The page/pkt requirement is not added by this patch.  The earlier
> XDP patch series has already ensured this page/pkt requirement
> is effective only when XDP prog is attached.
> 
> In the earlier XDP patches, MTU is limited to 1514 when
> XDP is ative.   This patch is to allow fully use of the
> page for a packet (and also only matter when XDP is active).

OK, thanks for the clarification.

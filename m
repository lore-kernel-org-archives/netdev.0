From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net v2] net/mlx5e: Fix race in mlx5e_sw_stats and
 mlx5e_vport_stats
Date: Thu, 20 Apr 2017 09:50:11 -0700
Message-ID: <20170420165011.66lx7gm5e3bk7k67@kafai-mba.dhcp.thefacebook.com>
References: <20170419233259.2255806-1-kafai@fb.com>
 <CALzJLG_r4x2PvVTG8vdDRFfGBfRe-totyUaPtV8ehmqiL0dURA@mail.gmail.com>
 <20170420141526.maq6b6rgqfjcdyn6@kafai-mba.dhcp.thefacebook.com>
 <1492700441.22296.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Gal Pressman <galp@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36818 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S944067AbdDTQuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:50:22 -0400
Content-Disposition: inline
In-Reply-To: <1492700441.22296.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 08:00:41AM -0700, Eric Dumazet wrote:
> On Thu, 2017-04-20 at 07:15 -0700, Martin KaFai Lau wrote:
>
> > A follow-up patch approach by Gal will be nice.
>
> Note that I had a similar issue on mlx4.
>
> Stats are cleared/reset at open time, but in an asynchronous way.
>
> Using a bonding device ( and fix in
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=142c6594acbcc32391af9c15f8cd65c6c177698f ) worked around the problem.
We also drop the X->0 delta now but does not drop the 0->Y delta.

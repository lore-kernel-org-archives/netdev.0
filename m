From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net/mlx5e: Fix race in mlx5e_sw_stats and
 mlx5e_vport_stats
Date: Thu, 20 Apr 2017 08:00:41 -0700
Message-ID: <1492700441.22296.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170419233259.2255806-1-kafai@fb.com>
         <CALzJLG_r4x2PvVTG8vdDRFfGBfRe-totyUaPtV8ehmqiL0dURA@mail.gmail.com>
         <20170420141526.maq6b6rgqfjcdyn6@kafai-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Gal Pressman <galp@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:33200 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970239AbdDTPAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:00:43 -0400
Received: by mail-yb0-f193.google.com with SMTP id 206so4242210ybe.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:00:43 -0700 (PDT)
In-Reply-To: <20170420141526.maq6b6rgqfjcdyn6@kafai-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 07:15 -0700, Martin KaFai Lau wrote:

> A follow-up patch approach by Gal will be nice.

Note that I had a similar issue on mlx4.

Stats are cleared/reset at open time, but in an asynchronous way.

Using a bonding device ( and fix in
https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=142c6594acbcc32391af9c15f8cd65c6c177698f ) worked around the problem.

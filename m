From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Mon, 5 Dec 2016 17:46:33 +0000
Message-ID: <20161205174633.69e71432@jkicinski-Precision-T1700>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
        <1480721013-1047541-3-git-send-email-kafai@fb.com>
        <ba7950ad-d469-5e98-6ed1-ded9f58dba6b@hpe.com>
        <20161204031958.GD70461@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:56007 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbcLERqj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 12:46:39 -0500
In-Reply-To: <20161204031958.GD70461@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Dec 2016 19:19:58 -0800, Martin KaFai Lau wrote:
> AFAIK, only mlx4/5 supports XDP now.

That is, unfortunately, not true.

$ git checkout net-next/master
$ git grep ndo_xdp drivers/
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: .ndo_xdp                = mlx4_xdp,
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: .ndo_xdp                = mlx4_xdp,
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:      .ndo_xdp                 = mlx5e_xdp,
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:      .ndo_xdp                 = mlx5e_xdp,
drivers/net/ethernet/netronome/nfp/nfp_net_common.c:    .ndo_xdp                = nfp_net_xdp,
drivers/net/ethernet/qlogic/qede/qede_main.c:   .ndo_xdp = qede_xdp,

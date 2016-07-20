From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: fix implicit declaration of bpf_prog_add
Date: Wed, 20 Jul 2016 11:59:32 -0700 (PDT)
Message-ID: <20160720.115932.1415271861583397757.davem@davemloft.net>
References: <1469026552-8975-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ttoukan.linux@gmail.com
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcGTS7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 14:59:35 -0400
In-Reply-To: <1469026552-8975-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Wed, 20 Jul 2016 07:55:52 -0700

> For the ifndef case of CONFIG_BPF_SYSCALL, an inline version of
> bpf_prog_add needs to exist otherwise the build breaks on some configs.
> 
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2544:10: error: implicit declaration of function 'bpf_prog_add'
>        prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> 
> The function is introduced in
> 59d3656d5bf50 ("bpf: add bpf_prog_add api for bulk prog refcnt")
> and first used in
> 47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program").
> 
> Fixes: 47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Reported-by: Tariq Toukan <ttoukan.linux@gmail.com>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Applied.

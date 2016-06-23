From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v2] net/mlx5: use mlx5_buf_alloc_node instead of
 mlx5_buf_alloc in mlx5_wq_ll_create
Date: Thu, 23 Jun 2016 10:34:11 +0300
Message-ID: <CALzJLG87Pcp=S90rLe=6r5D83HqeeTk9ZritjgrGA3kT0KQ8kA@mail.gmail.com>
References: <1466643847-42411-1-git-send-email-shhuiw@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, stable@vger.kernel.org
To: Wang Sheng-Hui <shhuiw@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35803 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbcFWHeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 03:34:31 -0400
Received: by mail-yw0-f196.google.com with SMTP id v77so9542211ywg.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 00:34:31 -0700 (PDT)
In-Reply-To: <1466643847-42411-1-git-send-email-shhuiw@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 4:04 AM, Wang Sheng-Hui <shhuiw@foxmail.com> wrote:
> Fixes: 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on
> reader NUMA node")
>

Hi Wang,

I am sorry for the nitpicking, but the commit message needs to be improved.

I prefer putting the "Fixes" line only after the bug description
(commit message) just before the Signed-of-by line. you can find some
examples in the commit log history.

>
> Change since V1:
>         * Add Fixes line in commit log
>

This should come only after the "---" below so it won't appear in the
commit log.

http://kernelnewbies.org/FirstKernelPatch#head-5c81b3c517a1d0bbc24f92594cb734e155fcbbcb

> Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>
> ---

["Changes since" goes here]

>  drivers/net/ethernet/mellanox/mlx5/core/wq.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
>

Thanks,
Saeed

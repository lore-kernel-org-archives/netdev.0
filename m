From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH v3] net/mlx5: use mlx5_buf_alloc_node instead of
 mlx5_buf_alloc in mlx5_wq_ll_create
Date: Sun, 26 Jun 2016 13:02:17 +0300
Message-ID: <CALzJLG88Nhe6qz1HStWkNnHvkQAzRDoh9Z+w1M0S96AG3uVomA@mail.gmail.com>
References: <1466729531-45481-1-git-send-email-shhuiw@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wang Sheng-Hui <shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466729531-45481-1-git-send-email-shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2016 at 3:52 AM, Wang Sheng-Hui <shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org> wrote:
> Commit 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on
> reader NUMA node") introduced mlx5_*_alloc_node() but missed changing
> some calling and warn messages. This patch introduces 2 changes:
>         * Use mlx5_buf_alloc_node() instead of mlx5_buf_alloc() in
>           mlx5_wq_ll_create()
>         * Update the failure warn messages with _node postfix for
>           mlx5_*_alloc function names
>
> Fixes: 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on reader NUMA node")
> Signed-off-by: Wang Sheng-Hui <shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>

Acked-By: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

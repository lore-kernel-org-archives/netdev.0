From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/mlx5: use mlx5_buf_alloc_node insteaf of
 mlx5_buf_alloc in mlx5_wq_ll_create
Date: Wed, 22 Jun 2016 13:46:01 +0300
Message-ID: <CALzJLG8HvO7-i129g=spKPxjfO2wVyqV0jB0zfhNOcZqyrWMqQ@mail.gmail.com>
References: <1466582798-41187-1-git-send-email-shhuiw@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wang Sheng-Hui <shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466582798-41187-1-git-send-email-shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2016 at 11:06 AM, Wang Sheng-Hui <shhuiw-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org> wrote:
> This patch introduces 2 changes:
>         * use mlx5_buf_alloc_node() insteaf of mlx5_buf_alloc() in

insteaf => instead

>           mlx5_wq_ll_create
>         * Update the failure warn messages with _node postfix for mlx5_*_alloc
>           function names
>

Nice catch,

Please add Fixes line, and let's take it to net and -stable.
Fixes: 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on
reader NUMA node")

Can i ask how did you hit this ? did you see any performance impact on RX?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

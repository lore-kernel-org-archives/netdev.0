From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [for-next V2 06/10] net/mlx5: Add interface to get reference to a UAR
Date: Mon, 9 Jan 2017 10:31:36 +0200
Message-ID: <CALzJLG-yiZfa6J0WciFPowfF2LWrXAqCKc4ETu4x=ZJdn+CfDA@mail.gmail.com>
References: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
 <1483890891-8767-7-git-send-email-saeedm@mellanox.com> <20170108170539.GA6323@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170108170539.GA6323-Hxa29pjIrETlQW142y8m19+IiqhCXseY@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 8, 2017 at 7:05 PM, Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On Sun, Jan 08, 2017 at 05:54:47PM +0200, Saeed Mahameed wrote:
>> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>>       err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
>>                                MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
>> -                              "mlx5_cmd_eq", &dev->priv.bfregi.uars[0],
>> -                              MLX5_EQ_TYPE_ASYNC);
>> +                              "mlx5_cmd_eq",  MLX5_EQ_TYPE_ASYNC);
>
> Remove extra space
>

Hi Yuval, thanks for the review,
We will submit an incremental patch for this, as checkpatch doesn't
complain about such minor things.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v9 06/15] mlx5: Replace PCI pool old API
Date: Tue, 23 May 2017 11:26:58 -0400 (EDT)
Message-ID: <20170523.112658.1479025487863881513.davem@davemloft.net>
References: <20170522164907.22915-7-romain.perier@collabora.com>
        <20170523072743.GJ17751@mtr-leonro.local>
        <18745ec7-020a-a3d2-3e50-6a2405baaac2@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org
To: romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18745ec7-020a-a3d2-3e50-6a2405baaac2-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Date: Tue, 23 May 2017 10:53:36 +0200

> Hello,
> 
> 
> Le 23/05/2017 à 09:27, Leon Romanovsky a écrit :
>> On Mon, May 22, 2017 at 06:48:58PM +0200, Romain Perier wrote:
>>> The PCI pool API is deprecated. This commit replaces the PCI pool old
>>> API by the appropriate function with the DMA pool API.
>>>
>>> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>>> Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>>> Acked-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> Tested-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>>>  include/linux/mlx5/driver.h                   |  2 +-
>>>  2 files changed, 7 insertions(+), 6 deletions(-)
>>>
>> Who is supposed to merge this patch series?
>>
>> Acked-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Each maintainer of the corresponding subsystem, can take a patch, I
> guess. No ?

It might be easier to accumulate acks and you submit them as a series,
in my opinion.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

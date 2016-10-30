From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH for-next 00/14][PULL request] Mellanox mlx5 core driver
 updates 2016-10-25
Date: Sun, 30 Oct 2016 11:59:57 +0200
Message-ID: <CALzJLG8cN0VUiTHDdkgibObA970UsAP+E7E=DSgY1RKNefSyzA@mail.gmail.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com> <20161028.135309.1712496950641242201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161028.135309.1712496950641242201.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 7:53 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>
> I really disalike pull requests of this form.
>
> You add lots of datastructures and helper functions but no actual
> users of these facilities to the driver.
>
> Do this instead:
>
>         1) Add TSAR infrastructure
>         2) Add use of TSAR facilities to the driver
>
> That's one pull request.
>
> I don't care if this is hard, or if there are entanglements with
> Infiniband or whatever, you must submit changes in this manner.
>

It is not hard, it is just not right,  we have lots of IB and ETH
features that we would like to submit in the same kernel cycle,
with your suggestion I will have to almost submit every feature (core
infrastructure and netdev/RDMA usage)
to you and Doug.  Same for rdma features,  you will receive PULL
request for them as well,
I am sure you and the netdev list don't need such noise.  do not
forget that this will slow down mlx5 progress since
netde will block rdma and vise-versa.

> I will not accept additions to a driver that don't even get really
> used.

For logic/helper functions containing patches such as "Add TSAR
infrastructure" I agree and i can find a way to move some code around
to
avoid future conflicts and remove them from such pull requests.

but you need to at least accept hardware related structures
infrastructure patches for shared code such as
include/linux/mlx5/mlx5_ifc.h where we have only hardware definitions
and those patches are really minimal.

So bottom line, I will do my best to ensure future PULL requests will
contain only include/linux/mlx5/*.h hardware related definitions
or fully implemented features.

Can we agree on that ?

Thanks,
Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 00/11] net: Fix netdev adjacency tracking
Date: Fri, 14 Oct 2016 10:17:30 -0400 (EDT)
Message-ID: <20161014.101730.404820561372500741.davem@davemloft.net>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org
To: dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476305519-28833-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Date: Wed, 12 Oct 2016 13:51:48 -0700

> The netdev adjacency tracking is failing to create proper dependencies
> for some topologies. For example this topology
> 
>         +--------+
>         |  myvrf |
>         +--------+
>           |    |
>           |  +---------+
>           |  | macvlan |
>           |  +---------+
>           |    |
>       +----------+
>       |  bridge  |
>       +----------+
>           |
>       +--------+
>       | bond0  |
>       +--------+
>           |
>       +--------+
>       |  eth3  |
>       +--------+
> 
> hits 1 of 2 problems depending on the order of enslavement. The base set of
> commands for both cases:
> 
>     ip link add bond1 type bond
>     ip link set bond1 up

Your diagram uses the device name "bond0" but all of your command examples
use "bond1".  Please fix this up, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

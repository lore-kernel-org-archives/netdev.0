From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch v4 1/2] netlink: add reference of module in
 netlink_dump_start
Date: Sun, 07 Oct 2012 00:31:17 -0400 (EDT)
Message-ID: <20121007.003117.530528242235438911.davem@davemloft.net>
References: <1349417749-24869-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	jengelh-9+2X+4sQBs8@public.gmane.org
To: gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349417749-24869-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Fri, 5 Oct 2012 14:15:48 +0800

> I get a panic when I use ss -a and rmmod inet_diag at the
> same time.
> 
> it's because netlink_dump use inet_diag_dump witch function
> belongs to module inet_diag.
> 
> I search the codes and find many modules have the same problem.
> We need add reference of the module which the cb->dump belongs
> to.
> 
> Thanks for all help from Stephen,Jan,Eric,Steffen and Pablo.
> 
> Change From v3:
> change netlink_dump_start to inline,suggestion from Pablo and
> Eric.
> 
> Change From v2:
> delete netlink_dump_done,and call module_put in netlink_dump
> and netlink_sock_destruct.
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

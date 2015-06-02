From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net/mlx4: fix typo in mlx4_set_vf_mac
Date: Tue, 2 Jun 2015 08:58:25 +0300
Message-ID: <CAJ3xEMhBOYOHaQ+xatUEFyt2o3bnSFGFAa+awJEpdNQ-Lvq23A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, jackm@mellanox.com,
	brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:33006 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbFBF6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:58:25 -0400
Received: by obbnx5 with SMTP id nx5so120045621obb.0
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 22:58:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2015 at 5:41 PM,  <clsoto@linux.vnet.ibm.com> wrote:
> fix typo in mlx4_set_vf_mac
>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2687,7 +2687,7 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev
>         port = mlx4_slaves_closest_port(dev, slave, port);
>         s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
>         s_info->mac = mac;
> -       mlx4_info(dev, "default mac on vf %d port %d to %llX will take afect only after vf restart\n",
> +       mlx4_info(dev, "default mac on vf %d port %d to %llX will take effect only after vf restart\n",
>                   vf, port, s_info->mac);
>         return 0;
>  }

Hi Carol,

Thanks for the fixes, will look on the other two today and provide feedback.

As for this one: please re-send the patch and target it to net-next
(i.e have [PATCH net-next] on the subject line and generate it against
the net-next tree
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git).

Also, we use some conventions in our commits, will be happy if you can
pick on them:

-- have "net/mlx4_core:" prefix
-- use capital letter in the 1st word of the subject line, that is

so [PATCH net] net/mlx4: fix typo in mlx4_set_vf_mac

becomes

[PATCH net-next] net/mlx4_core: Fix typo in mlx4_set_vf_mac

You can add my ack

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Or.

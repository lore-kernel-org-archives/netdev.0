From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net/mlx4: need to call close fw if alloc icm is
 called twice
Date: Tue, 2 Jun 2015 10:25:11 +0300
Message-ID: <CAJ3xEMgc1grcF5Qb9i6u+7kvtC63qimOT3VoUeu+m12yn88-JQ@mail.gmail.com>
References: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<1433169704-32307-2-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@mellanox.com>,
	brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33109 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004AbbFBHZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 03:25:12 -0400
Received: by oiww2 with SMTP id w2so119439019oiw.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 00:25:11 -0700 (PDT)
In-Reply-To: <1433169704-32307-2-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2015 at 5:41 PM,  <clsoto@linux.vnet.ibm.com> wrote:
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2837,6 +2837,7 @@ slave_start:
>                                                                   existing_vfs,
>                                                                   reset_flow);
>
> +                               mlx4_close_fw(dev);
>                                 mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
>                                 dev->flags = dev_flags;
>                                 if (!SRIOV_VALID_STATE(dev->flags)) {
>

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

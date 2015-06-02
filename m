From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net/mlx4: double free of dev_vfs
Date: Tue, 2 Jun 2015 10:25:42 +0300
Message-ID: <CAJ3xEMhnEGxAhwBcW4DpLGO9zgR2JymRWHJ-WiJOx1S5+iwFGw@mail.gmail.com>
References: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@mellanox.com>,
	brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33392 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbFBHZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 03:25:43 -0400
Received: by oiww2 with SMTP id w2so119446171oiw.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 00:25:42 -0700 (PDT)
In-Reply-To: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2015 at 5:41 PM,  <clsoto@linux.vnet.ibm.com> wrote:
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2685,6 +2685,7 @@ disable_sriov:
>  free_mem:
>         dev->persist->num_vfs = 0;
>         kfree(dev->dev_vfs);
> +       dev->dev_vfs = NULL;
>         return dev_flags & ~MLX4_FLAG_MASTER;
>  }

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

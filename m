From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4: Handle return codes in mlx4_qp_attach_common
Date: Mon, 28 Sep 2015 22:26:42 -0700 (PDT)
Message-ID: <20150928.222642.1395622340146984028.davem@davemloft.net>
References: <CAM5t4r_uaRPJT0kiaqNkygu1ciCoVSVQhj5MLkn69uieXx1MHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, eyalpe@mellanox.com,
	ogerlitz@mellanox.com
To: rmanes@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbI2F0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:26:43 -0400
In-Reply-To: <CAM5t4r_uaRPJT0kiaqNkygu1ciCoVSVQhj5MLkn69uieXx1MHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robb Manes <rmanes@redhat.com>
Date: Fri, 25 Sep 2015 10:39:21 -0400

> @@ -1184,10 +1184,11 @@ out:
>      if (prot == MLX4_PROT_ETH) {
>          /* manage the steering entry for promisc mode */
>          if (new_entry)
> -            new_steering_entry(dev, port, steer, index, qp->qpn);
> +            err = new_steering_entry(dev, port, steer,
> +                         index, qp->qpn);
>          else
> -            existing_steering_entry(dev, port, steer,
> -                        index, qp->qpn);
> +            err = existing_steering_entry(dev, port, steer,
> +                              index, qp->qpn);

Please indent this properly.

When a function call spans multiple lines, the second and
subsequent lines must start precisely at the first column
after the openning parenthesis of the first line.  You must
use the appropriate number of TAB then SPACE characters
necessary to achieve this.

Thanks.

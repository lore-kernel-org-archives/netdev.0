From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mlx4_en: Pause parameters per port
Date: Thu, 06 Nov 2008 00:45:22 -0500
Message-ID: <49128472.7080607@pobox.com>
References: <4911B244.30205@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46659 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbYKFFpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:45:36 -0500
In-Reply-To: <4911B244.30205@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
> Before the change the driver reported the same pause parameters
> for all the ports, even only one of them was modified.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/en_netdev.c |    8 ++++----
>  drivers/net/mlx4/en_params.c |   30 ++++++++++++++++--------------
>  drivers/net/mlx4/mlx4_en.h   |    8 ++++----
>  3 files changed, 24 insertions(+), 22 deletions(-)

Is this a regression fix?  It doesn't look like one to me, so I am 
planning to hold this for 2.6.29 (davem/net-next-2.6.git), unless there 
are problems with this plan?

	Jeff





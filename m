From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 4/4] forcedeth: advertise transmit time stamping
Date: Mon, 23 Jul 2012 09:27:18 -0400
Message-ID: <CA+FuTSd5xuzhUA+vr+xrfVd7Y3AzxZurqAXy5bUfZdFKTbAYow@mail.gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com> <d95c3b5bf30e3a7d056ad7f9fb774bbf572dc217.1342976654.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59582 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325Ab2GWN1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 09:27:50 -0400
Received: by lbbgm6 with SMTP id gm6so8026097lbb.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 06:27:49 -0700 (PDT)
In-Reply-To: <d95c3b5bf30e3a7d056ad7f9fb774bbf572dc217.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 22, 2012 at 1:15 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This driver now offers software transmit time stamping, so it should
> advertise that fact via ethtool. Compile tested only.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Willem de Bruijn <willemb@google.com>

> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/nvidia/forcedeth.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index 67edc2e..f45def0 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -5182,6 +5182,7 @@ static const struct ethtool_ops ops = {
>         .get_ethtool_stats = nv_get_ethtool_stats,
>         .get_sset_count = nv_get_sset_count,
>         .self_test = nv_self_test,
> +       .get_ts_info = ethtool_op_get_ts_info,
>  };
>
>  /* The mgmt unit and driver use a semaphore to access the phy during init */
> --
> 1.7.2.5
>

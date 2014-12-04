From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 2/2] rocker: fix eth_type type in struct rocker_ctrl
Date: Thu, 4 Dec 2014 12:33:43 -0800
Message-ID: <CAE4R7bBm0xt9EiqAjTwZoAuYD6Vx6i=4ix+euWP02COkXEfvng@mail.gmail.com>
References: <1417612494-3788-1-git-send-email-jiri@resnulli.us>
	<1417612494-3788-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:45199 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025AbaLDUdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 15:33:45 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so35956629wiv.11
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 12:33:43 -0800 (PST)
In-Reply-To: <1417612494-3788-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

On Wed, Dec 3, 2014 at 5:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> v1->v2:
> -fixed typo in subject pointed out by Sergei
> ---
>  drivers/net/ethernet/rocker/rocker.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 4b060fb..5536435 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -2753,7 +2753,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
>  static struct rocker_ctrl {
>         const u8 *eth_dst;
>         const u8 *eth_dst_mask;
> -       u16 eth_type;
> +       __be16 eth_type;
>         bool acl;
>         bool bridge;
>         bool term;
> --
> 1.9.3
>

From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 06/10] netdev: add netdevice notifier type to
 trigger a reprogramming of offloads
Date: Sat, 9 Jan 2016 09:25:13 -0800
Message-ID: <CALx6S357fYzhCRHsPAjX+NH+5Wc1tnUuNwcZ5oy3WiAMASjOEA@mail.gmail.com>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
	<1452352052-27574-7-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35645 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbcAIRZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 12:25:14 -0500
Received: by mail-ig0-f194.google.com with SMTP id mw1so9883913igb.2
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 09:25:14 -0800 (PST)
In-Reply-To: <1452352052-27574-7-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 9, 2016 at 7:07 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/netdevice.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8d8e5ca951b493..9750e46760695d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
>  #define NETDEV_BONDING_INFO    0x0019
>  #define NETDEV_PRECHANGEUPPER  0x001A
>  #define NETDEV_CHANGELOWERSTATE        0x001B
> +#define NETDEV_REFRESH_OFFLOADS        0x001C
>
Per previous discussion we don't want to generalize this current
offload interface. Can we just NETDEV_UP as the notifier?

>  int register_netdevice_notifier(struct notifier_block *nb);
>  int unregister_netdevice_notifier(struct notifier_block *nb);
> --
> 2.5.0
>
